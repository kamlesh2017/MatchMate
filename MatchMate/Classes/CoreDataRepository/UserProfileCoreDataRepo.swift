//
//  UserProfileCoreDataRepo.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//

import CoreData

class UserProfileCoreDataRepo {
    // Fetch all profiles
    func fetchProfiles() -> [CDUserProfile] {
        let fetchRequest: NSFetchRequest<CDUserProfile> = CDUserProfile.fetchRequest()
        do {
            return try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch profiles: \(error)")
            return []
        }
    }

    // Create a profile
    func addProfile(id: String?, name: String, age: Float, location: String, imageURL: String?, status: String) {
        let newProfile = CDUserProfile(context: CoreDataManager.shared.context)
        newProfile.id = id
        newProfile.name = name
        newProfile.age = age
        newProfile.location = location
        newProfile.imageURL = imageURL
        newProfile.status = status
        CoreDataManager.shared.saveContext()
    }

    // Update profile status
    func updateProfileStatus(id: String, status: String) {
        let fetchRequest: NSFetchRequest<CDUserProfile> = CDUserProfile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let results = try CoreDataManager.shared.context.fetch(fetchRequest)
            if let profile = results.first {
                profile.status = status
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Failed to update profile status: \(error)")
        }
    }
}
