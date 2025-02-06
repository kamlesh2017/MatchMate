//
//  Models.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 26/01/25.
//

import Foundation
import Combine

final class ProfilesViewModel: ObservableObject, ProfileCardViewDelegate {
    @Published var profiles: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var currentPage = 1
    private var pageSize = 3
    private(set) var hasMoreData = true
    
    let networkManager: NetworkManager
    let coreDataRepo: UserProfileCoreDataRepo
    
    init(networkManager: NetworkManager, coreDataRepo: UserProfileCoreDataRepo) {
        self.networkManager = networkManager
        self.coreDataRepo = coreDataRepo
    }

    func loadInitialProfiles() {
        errorMessage = nil
        profiles = []
        hasMoreData = true
        loadMoreProfiles()
    }

    func loadMoreProfiles() {
        guard hasMoreData && !isLoading else { return }
        isLoading = true

        // Fetch paginated data from Core Data first
        coreDataRepo.fetchProfiles(fetchOffset: profiles.count, fetchLimit: pageSize) { [weak self] coreDataProfiles in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if NetworkMonitor.shared.isReachable {
                    // Fetch additional data from API
                    self.fetchProfilesFromAPI() { apiProfiles in
                        DispatchQueue.main.async {
                            if !apiProfiles.isEmpty {
                                let syncProfiles = self.coreDataRepo.syncProfilesWithCoreData(coreDataProfiles: coreDataProfiles, apiProfiles: apiProfiles)
                                self.profiles.append(contentsOf: syncProfiles)
                                self.currentPage += 1
                            } else {
                                self.hasMoreData = false
                            }
                            self.isLoading = false
                        }
                    }
                } else {
                    if !coreDataProfiles.isEmpty {
                        self.profiles.append(contentsOf: coreDataProfiles)
                    } else {
                        debugPrint("Check internet connection")
                    }
                    self.isLoading = false
                }
            }
        }
    }

    private func fetchProfilesFromAPI(completion: @escaping ([UserProfile]) -> Void) {
        networkManager.fetchProfiles(page: self.currentPage, pageSize: pageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profiles):
                let userProfiles = self.getUserProfiles(from: profiles)
                completion(userProfiles)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func getUserProfiles(from apiProfiles: [UserProfileResponse]) -> [UserProfile] {
        var userProfiles = [UserProfile]()
        for profile in apiProfiles {
            let id = profile.email ?? ""
            let name = "\(profile.name?.title ?? "") \(profile.name?.first ?? "") \(profile.name?.last ?? "")"
            let location = "\(profile.location?.city ?? ""), \(profile.location?.state ?? "")"
            let imageURL = profile.picture?.large
            let age = profile.registered?.age ?? 0

            let userProfile = UserProfile(id: id, name: name, imageURL: imageURL, location: location, age: age, status: .none)
            userProfiles.append(userProfile)
        }

        return userProfiles
    }
    
    // Accept or decline a profile
    func updateProfileStatus(index: Int, status: UserProfileStatus) {
        var profile = profiles[index]
        coreDataRepo.updateProfileStatus(id: profile.id, status: status.rawValue)
        profile.status = status
        profiles[index] = profile
    }
}

struct UserProfile {
    var id: String
    var name: String?
    var imageURL: String?
    var location: String?
    var age: Float
    var status: UserProfileStatus
    
    init(id: String, name: String?, imageURL: String?, location: String?, age: Float, status: UserProfileStatus) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.location = location
        self.age = age
        self.status = status
    }
}

enum UserProfileStatus: String {
    case accepted
    case declined
    case none
}
