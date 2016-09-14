//
//  Callback.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 3/18/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData
import CoreDataImportKit

class Callback: NSManagedObject {


    func shouldBuildRelationship(_ relationship: String, withRelationshipRepresentation relationshipRepresentation: CDIExternalRepresentation, fromRepresentation representaiton: CDIRepresentation) -> Bool {
        self.calledShouldBuildRelationship = true

        if let shouldBuildRelationship = representaiton["shouldBuildRelationship"] as? NSNumber {
            return shouldBuildRelationship.boolValue
        }
        else {
            return false
        }
    }

    func shouldImport(_ representation: CDIRepresentation) -> Bool {
        self.calledShouldImport = true
        
        if let shouldImportNumber = representation["shouldImport"] as? NSNumber {
            return shouldImportNumber.boolValue
        }
        else {
            return true
        }
    }

    func shouldImportAttribute(_ attributeName: String, withData data: AnyObject, inRepresentation representation: CDIRepresentation) -> Bool {
        self.calledShouldImportAttribute = true

        if let shouldImportAttributeNumber = representation["shouldImportAttribute"] as? NSNumber {
                return shouldImportAttributeNumber.boolValue
        }
        else {
            return true
        }
    }

    func willImport(_ representation: CDIRepresentation) {
        self.calledWillImport = NSNumber(value: true)
    }

    func didImport(_ representation: CDIRepresentation) {
        self.calledDidImport = NSNumber(value: true)
    }
}
