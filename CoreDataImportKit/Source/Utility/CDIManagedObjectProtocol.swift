//
//  CDIManagedObjectProtocol.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/23/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

@objc protocol CDIManagedObjectProtocol {
    optional func shouldBuildRelationship(relationship: String, withRelationshipRepresentation relationshipRepresentation: CDIExternalRepresentation, fromRepresentation representaiton: CDIRepresentation) -> Bool
    optional func shouldImport(representation: CDIRepresentation) -> Bool
    optional func shouldImportAttribute(attributeName: String, inRepresentation representation: CDIRepresentation) -> Bool
    optional func willImport(representation: CDIRepresentation)
    optional func didImport(representation: CDIRepresentation)
}

extension NSManagedObject : CDIManagedObjectProtocol {}