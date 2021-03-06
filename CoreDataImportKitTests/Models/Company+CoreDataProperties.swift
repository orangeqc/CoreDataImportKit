//
//  Company+CoreDataProperties.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/25/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Company {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var founded: String?
    @NSManaged var employees: NSSet?
    @NSManaged var computers: NSSet?

}
