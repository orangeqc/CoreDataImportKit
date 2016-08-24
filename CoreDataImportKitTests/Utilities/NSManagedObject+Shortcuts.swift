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
        var predicate : NSPredicate
        if let value = value as? String {
            predicate = NSPredicate(format: "\(attribute) == '\(value)'")
        }
        else {
            predicate = NSPredicate(format: "\(attribute) == \(value)")
        }

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
        
        var count: Int = 0
        do {
            count = try context.countForFetchRequest(fetchRequest)
        }
        catch {
            print("Error finding count in \(String(self)): \(error)")
        }
        return count
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
