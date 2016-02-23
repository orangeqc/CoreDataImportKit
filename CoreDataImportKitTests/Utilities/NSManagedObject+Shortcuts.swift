//
//  NSManagedObject+Shortcuts.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/19/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    class func findFirstByAttribute<T: NSManagedObject>(attribute: String, withValue value: NSObject, inContext context: NSManagedObjectContext) -> T? {
        let fetchRequest = NSFetchRequest(entityName: String(T))
        let predicate = NSPredicate(format: "\(attribute) = \(value)")
        fetchRequest.predicate = predicate

        do {
            return try context.executeFetchRequest(fetchRequest).first as? T
        }
        catch {
            return nil
        }
    }

    class func countInContext(context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest(entityName: String(self))

        var error: NSError? = nil
        let count = context.countForFetchRequest(fetchRequest, error: &error)
        if let e = error {
            print("Error finding count in \(String(self)): \(e)")
            return 0
        }
        else {
            return count
        }
    }

    class func createObjectWithAttributes<T: NSManagedObject>(attributes: [ String: NSObject ], inContext context: NSManagedObjectContext) -> T {

        let entity = NSEntityDescription.entityForName(String(T), inManagedObjectContext: context)
        let object = NSEntityDescription.insertNewObjectForEntityForName(String(T), inManagedObjectContext: context) 

        for (attributeName, value) in attributes {
            if entity?.attributesByName.keys.indexOf(attributeName) != nil {
                object.setValue(value, forKey: attributeName)
            }
        }

        return object as! T
    }

}