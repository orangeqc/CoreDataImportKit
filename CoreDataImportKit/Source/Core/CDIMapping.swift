//
//  CDIMapping.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/11/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

public class CDIMapping {
    public let entityName: String
    public var hasPrimaryKey: Bool {
        get {
            return primaryKey != nil
        }
    }

    let context: NSManagedObjectContext
    let entityDescription: NSEntityDescription
    let primaryKey: String?

    init(entityName: String, inManagedObjectContext context: NSManagedObjectContext) {
        self.entityName = entityName
        self.context = context

        let description = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        assert(description != nil)
        self.entityDescription = description!

        self.primaryKey = entityDescription.userInfo?["relatedByAttribute"] as? String
    }

    public func createManagedObjectWithRepresentation(representation: [ String : AnyObject ]) -> NSManagedObject {

        let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)

        if primaryKey != nil {
            if let attribute = entityDescription.attributesByName[primaryKey!] {
                if let representationValue = representation[lookupKeyForAttribute(attribute)] {
                    object.setValue(representationValue, forKey: primaryKey!)
                }
            }
        }

        return object
    }

    // ["mappedKeyName"]
    func lookupKeyForAttribute(attribute: NSAttributeDescription) -> String {
        if let userInfo = attribute.userInfo {
            if let mappedKeyName = userInfo["mappedKeyName"] as? String {
                return mappedKeyName
            }
        }

        return attribute.name
    }
}