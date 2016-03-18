//
//  Callback+CoreDataProperties.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 3/18/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Callback {

    @NSManaged var calledShouldImport: NSNumber?
    @NSManaged var calledShouldImportAttribute: NSNumber?
    @NSManaged var calledDidImport: NSNumber?
    @NSManaged var calledWillImport: NSNumber?
    @NSManaged var calledShouldBuildRelationship: NSNumber?
    @NSManaged var testAttribute: String?
    @NSManaged var id: NSNumber?
    @NSManaged var everyAttribute: EveryAttributeType?

}
