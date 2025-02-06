//
//  UserProfileCoreDataRepo.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//

import CoreData

class UserProfileCoreDataRepo {

    // Create a profile
    func addProfile(id: String?, name: String?, age: Float, location: String?, imageURL: String?, status: String) {
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
    
    // Fetch paginated profiles from Core Data
    func fetchProfiles(fetchOffset: Int, fetchLimit: Int, completion: @escaping ([UserProfile]) -> Void) {
        let fetchRequest: NSFetchRequest<CDUserProfile> = CDUserProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = fetchOffset
        
        do {
            let storedProfiles = try CoreDataManager.shared.context.fetch(fetchRequest)
            let mappedProfiles = storedProfiles.map { $0.convertToUserProfile() }
            completion(mappedProfiles)
        } catch {
            print("Failed to fetch profiles from Core Data: \(error)")
            completion([])
        }
    }

    func syncProfilesWithCoreData(coreDataProfiles: [UserProfile], apiProfiles: [UserProfile]) -> [UserProfile] {
        
        let uniqueKeysWithValues = coreDataProfiles.map { ($0.id, $0) }
        var storedProfileDict = Dictionary(uniqueKeysWithValues: uniqueKeysWithValues)
        
        var syncedProfiles: [UserProfile] = []

        for apiProfile in apiProfiles {
            let profileID = apiProfile.id
            if var existingProfile = storedProfileDict[profileID] {
                // Retain status and update other fields
                existingProfile.id = apiProfile.id
                existingProfile.name = apiProfile.name
                existingProfile.imageURL = apiProfile.imageURL
                existingProfile.location = apiProfile.location
                existingProfile.age = apiProfile.age
                syncedProfiles.append(existingProfile)
                storedProfileDict.removeValue(forKey: profileID)
            } else {
                // Create a new Core Data record
                addProfile(id: profileID, name: apiProfile.name, age: apiProfile.age, location: apiProfile.location, imageURL: apiProfile.imageURL, status: "none")
                syncedProfiles.append(apiProfile)
            }
        }

        // Remove outdated profiles only within the paginated range
        for (_, profileToRemove) in storedProfileDict {
            deleteProfile(byID: profileToRemove.id)
        }
        
        return syncedProfiles
    }
    
    func deleteProfile(byID id: String) {
        let fetchRequest: NSFetchRequest<CDUserProfile> = CDUserProfile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as String)
        do {
            if let object = try CoreDataManager.shared.context.fetch(fetchRequest).first {
                CoreDataManager.shared.context.delete(object)
                CoreDataManager.shared.saveContext()
                debugPrint("Deleted entity with id: \(id)")
            } else {
                debugPrint("Entity not found")
            }
        } catch {
            debugPrint("profile not found id=\(id)")
        }
    }
}
