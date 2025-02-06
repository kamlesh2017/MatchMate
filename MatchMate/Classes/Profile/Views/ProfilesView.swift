//
//  ProfilesView.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 26/01/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfilesView: View {
    @ObservedObject private var viewModel: ProfilesViewModel
    
    init(viewModel: ProfilesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading profiles...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(Array(viewModel.profiles.enumerated()), id: \.1.id) { index, profile in
                            ProfileCardView(profile: profile, index: index, delegate: viewModel)
                        }
                        if viewModel.hasMoreData {
                            VStack(alignment: .center) {
                                Button(action: {
                                    viewModel.loadMoreProfiles()
                                }) {
                                    Text("Load More Profiles")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("MatchMate")
            .onAppear {
                viewModel.loadInitialProfiles()
            }
        }
    }
    
    func checkForMoreProfiles() {
        viewModel.loadMoreProfiles()
    }
}

protocol ProfileCardViewDelegate: AnyObject {
    func updateProfileStatus(index: Int, status: UserProfileStatus)
}

struct ProfileCardView: View {
    let profile: UserProfile
    let index: Int
    weak var delegate: ProfileCardViewDelegate?

    var body: some View {
        VStack(spacing: 8) {
            WebImage(url: URL(string: profile.imageURL ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            VStack(alignment: .center, spacing: 4) {
                Text(profile.name ?? "")
                    .font(.headline)
                Text(profile.location ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if profile.status == .none {
                HStack(spacing: 12) {
                    Text("Accept")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .onTapGesture(perform: {
                        delegate?.updateProfileStatus(index: index, status: .accepted)
                    })

                    Text("Decline")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .onTapGesture(perform: {
                        delegate?.updateProfileStatus(index: index, status: .declined)
                    })
                }
                .frame(maxWidth: .infinity)
            } else {
                Text(profile.status.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(profile.status == .accepted ? .green : .red)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

struct ProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProfilesViewModel(networkManager: NetworkManager.shared, coreDataRepo: UserProfileCoreDataRepo())
        ProfilesView(viewModel: viewModel)
    }
}
