//
//  Computer+CoreDataProperties.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/29/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Computer {

    @NSManaged var purchased: Date?
    @NSManaged var cost: NSNumber?
    @NSManaged var name: String?
    @NSManaged var owner: Person?
    @NSManaged var company: Company?

}
