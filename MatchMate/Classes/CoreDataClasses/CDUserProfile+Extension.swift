//
//  Untitled.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//

extension CDUserProfile {
    func convertToUserProfile() -> UserProfile {
        return UserProfile(id: self.id ?? "", name: self.name, imageURL: self.imageURL, location: self.location, age: self.age, status: UserProfileStatus(rawValue: self.status ?? "none") ?? .none)
    }
}
