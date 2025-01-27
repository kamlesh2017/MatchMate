//
//  CDUserProfile+CoreDataProperties.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//
//

import Foundation
import CoreData


extension CDUserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserProfile> {
        return NSFetchRequest<CDUserProfile>(entityName: "CDUserProfile")
    }

    @NSManaged public var age: Float
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
}

extension CDUserProfile : Identifiable {

}
