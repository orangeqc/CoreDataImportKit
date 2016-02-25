//
//  EveryAttributeType+CoreDataProperties.swift
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

extension EveryAttributeType {

    @NSManaged var stringAttribute: String?
    @NSManaged var floatAttribute: NSNumber?
    @NSManaged var doubleAttribute: NSNumber?
    @NSManaged var decimalAttribute: NSDecimalNumber?
    @NSManaged var integerAttribute: NSNumber?
    @NSManaged var booleanAttribute: NSNumber?
    @NSManaged var dateAttribute: NSDate?
    @NSManaged var keyPathAttribute: String?
    @NSManaged var dateAttributeCustomized: NSDate?

}
