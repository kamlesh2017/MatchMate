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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.profiles, id: \.id) { profile in
                                ProfileCardView(profile: profile, onAction: { action in
                                    viewModel.updateProfileStatus(id: profile.id, status: action)
                                })
                                .onAppear {
                                    checkForMoreProfiles(profile)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("MatchMate")
            .onAppear {
                viewModel.loadProfiles()
            }
        }
    }
    
    func checkForMoreProfiles(_ profile: UserProfile) {
        if viewModel.profiles.last?.id == profile.id {
            viewModel.loadMoreProfiles()
        }
    }
}

struct ProfileCardView: View {
    let profile: UserProfile
    let onAction: (UserProfileStatus) -> Void

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
                    Button(action: {
                        onAction(.accepted)
                    }) {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        onAction(.declined)
                    }) {
                        Text("Decline")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
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
