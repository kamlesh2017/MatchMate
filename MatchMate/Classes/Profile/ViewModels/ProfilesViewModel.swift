//
//  Models.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 26/01/25.
//

import Foundation
import Combine

class ProfilesViewModel: ObservableObject {
    @Published var profiles: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var currentPage: Int {
        get {
            let page = UserDefaults.standard.integer(forKey: "currentPage")
            return page
        }
        
        set(newVal) {
            UserDefaults.standard.set(newVal, forKey: "currentPage")
        }
    }
    private let resultsPerPage: Int = 5
    
    let networkManager: NetworkManager
    let coreDataRepo: UserProfileCoreDataRepo
    
    
    init(networkManager: NetworkManager, coreDataRepo: UserProfileCoreDataRepo) {
        self.networkManager = networkManager
        self.coreDataRepo = coreDataRepo
        self.currentPage = UserDefaults.standard.integer(forKey: "currentPage") + 1
    }

    func loadProfiles() {
        if NetworkMonitor.shared.isReachable {
            self.fetchProfilesFromAPI()
        } else {
            self.loadFromCoreData()
        }
    }

    // Fetch profiles from Core Data
    private func loadFromCoreData() {
        let coreDataProfiles = coreDataRepo.fetchProfiles()
        self.profiles = coreDataProfiles.map { $0.convertToUserProfile() }
    }

    // Fetch profiles from API
    private func fetchProfilesFromAPI() {
        self.isLoading = true
        networkManager.fetchProfiles(results: resultsPerPage, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let apiProfiles):
                    self?.handleFetchedProfiles(apiProfiles)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Handle fetched profiles from API
    private func handleFetchedProfiles(_ apiProfiles: [UserProfileResponse]) {
        for profile in apiProfiles {
            let id = profile.email
            let name = "\(profile.name?.title ?? "") \(profile.name?.first ?? "") \(profile.name?.last ?? "")"
            let location = "\(profile.location?.city ?? ""), \(profile.location?.state ?? "")"
            let imageURL = profile.picture?.large
            let age = profile.registered?.age ?? 0

            // Check if the profile exists in Core Data
            let existingProfiles = coreDataRepo.fetchProfiles()
            if existingProfiles.first(where: { $0.id == id }) == nil {
                coreDataRepo.addProfile(id: id, name: name, age: age, location: location, imageURL: imageURL, status: "none")
            }
        }

        // Update the UI from Core Data
        self.loadFromCoreData()
    }

    // Accept or decline a profile
    func updateProfileStatus(id: String, status: UserProfileStatus) {
        coreDataRepo.updateProfileStatus(id: id, status: status.rawValue)
        self.loadFromCoreData()
    }

    // Load more profiles (pagination)
    func loadMoreProfiles() {
        currentPage += 1
        fetchProfilesFromAPI()
    }
}

struct UserProfile {
    let id: String
    let name: String?
    let imageURL: String?
    let location: String?
    let age: Float
    var status: UserProfileStatus
}

enum UserProfileStatus: String {
    case accepted
    case declined
    case none
}
