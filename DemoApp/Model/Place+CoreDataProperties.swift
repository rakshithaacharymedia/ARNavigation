//
//  Place+CoreDataProperties.swift
//  
//
//  Created by rakshitha on 22/09/18.
//
//

import Foundation
import CoreData

extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var typeofPlace: String?
    @NSManaged public var vicinity: String?

}
