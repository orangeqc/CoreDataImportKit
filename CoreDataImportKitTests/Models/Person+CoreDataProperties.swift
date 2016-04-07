//
//  Person+CoreDataProperties.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 4/7/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var age: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var computer: Computer?
    @NSManaged var job: Company?
    @NSManaged var boss: Person?
    @NSManaged var subordinates: NSSet?

}
