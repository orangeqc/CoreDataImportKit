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

    class func findFirstByAttribute<T: NSManagedObject>(_ attribute: String, withValue value: NSObject, inContext context: NSManagedObjectContext) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        var predicate : NSPredicate
        if let value = value as? String {
            predicate = NSPredicate(format: "\(attribute) == '\(value)'")
        }
        else {
            predicate = NSPredicate(format: "\(attribute) == \(value)")
        }

        fetchRequest.predicate = predicate

        do {
            return try context.fetch(fetchRequest).first
        }
        catch {
            return nil
        }
    }

    class func countInContext(_ context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: String(describing: self))
        
        var count: Int = 0
        do {
            count = try context.count(for: fetchRequest)
        }
        catch {
            print("Error finding count in \(String(describing: self)): \(error)")
        }
        return count
    }

    class func createObjectWithAttributes<T: NSManagedObject>(_ attributes: [ String: NSObject ], inContext context: NSManagedObjectContext) -> T {

        let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context)
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context)

        for (attributeName, value) in attributes {
            if entity?.attributesByName.keys.index(of: attributeName) != nil {
                object.setValue(value, forKey: attributeName)
            }
        }

        return object as! T
    }

}
