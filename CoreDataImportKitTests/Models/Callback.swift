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


    func shouldBuildRelationship(relationship: String, withRelationshipRepresentation relationshipRepresentation: CDIExternalRepresentation, fromRepresentation representaiton: CDIRepresentation) -> Bool {
        self.calledShouldBuildRelationship = true

        if let buildRelationship: Bool = (representaiton["shouldBuildRelationship"] as? NSNumber)!.boolValue {
            return buildRelationship
        }
        else {
            return false
        }
    }

    func shouldImport(representation: CDIRepresentation) -> Bool {
        self.calledShouldImport = true
        
        if let shouldImportNumber: NSNumber = (representation["shouldImport"] as? NSNumber),
            shouldImport: Bool = shouldImportNumber.boolValue {
            return shouldImport
        }
        else {
            return true
        }
    }

    func shouldImportAttribute(attributeName: String, inRepresentation representation: CDIRepresentation) -> Bool {
        self.calledShouldImportAttribute = true

        if let shouldImportAttributeNumber: NSNumber = (representation["shouldImportAttribute"] as? NSNumber),
            shouldImportAttribute: Bool = shouldImportAttributeNumber.boolValue {
                return shouldImportAttribute
        }
        else {
            return true
        }
    }

    func willImport(representation: CDIRepresentation) {
        self.calledWillImport = NSNumber(bool: true)
    }

    func didImport(representation: CDIRepresentation) {
        self.calledDidImport = NSNumber(bool: true)
    }
}
