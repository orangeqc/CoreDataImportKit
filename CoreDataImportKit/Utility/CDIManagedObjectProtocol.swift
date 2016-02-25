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
    optional func shouldBuildRelationship(relationship: String, withRepresentation representation: CDIRepresentation) -> Bool
    optional func shouldImport(representation: CDIRepresentation) -> Bool
    optional func willImport(representation: CDIRepresentation)
    optional func didImport(representation: CDIRepresentation)
}

extension NSManagedObject : CDIManagedObjectProtocol {}