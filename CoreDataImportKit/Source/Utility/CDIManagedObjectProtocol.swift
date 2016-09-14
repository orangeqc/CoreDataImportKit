//
//  CDIManagedObjectProtocol.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/23/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

@objc public protocol CDIManagedObjectProtocol {
    @objc optional func shouldBuildRelationship(_ relationship: String, withRelationshipRepresentation relationshipRepresentation: CDIExternalRepresentation, fromRepresentation representaiton: CDIRepresentation) -> Bool
    @objc optional func shouldImport(_ representation: CDIRepresentation) -> Bool
    @objc optional func shouldImportAttribute(_ attributeName: String, withData data: AnyObject, inRepresentation representation: CDIRepresentation) -> Bool
    @objc optional func willImport(_ representation: CDIRepresentation)
    @objc optional func didImport(_ representation: CDIRepresentation)
}

extension NSManagedObject : CDIManagedObjectProtocol {}
