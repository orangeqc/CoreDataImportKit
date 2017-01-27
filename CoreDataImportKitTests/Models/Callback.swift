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

        if let buildRelationship: Bool = (representaiton["shouldBuildRelationship"] as? NSNumber)!.boolValue {
            return buildRelationship
        }
        else {
            return false
        }
    }

    func shouldImport(_ representation: CDIRepresentation) -> Bool {
        self.calledShouldImport = true
        
        if let shouldImportNumber: NSNumber = (representation["shouldImport"] as? NSNumber),
            let shouldImport: Bool = shouldImportNumber.boolValue {
            return shouldImport
        }
        else {
            return true
        }
    }

    func shouldImportAttribute(_ attributeName: String, withData data: AnyObject, inRepresentation representation: CDIRepresentation) -> Bool {
        self.calledShouldImportAttribute = true

        if let shouldImportAttributeNumber: NSNumber = (representation["shouldImportAttribute"] as? NSNumber),
            let shouldImportAttribute: Bool = shouldImportAttributeNumber.boolValue {
                return shouldImportAttribute
        }
        else {
            return true
        }
    }

    func willImport(_ representation: CDIRepresentation) {
        self.calledWillImport = NSNumber(value: true as Bool)
    }

    func didImport(_ representation: CDIRepresentation) {
        self.calledDidImport = NSNumber(value: true as Bool)
    }
}
