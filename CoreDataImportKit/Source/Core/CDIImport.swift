//
//  CDIImport.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/19/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

public class CDIImport {

    let cache: CDIManagedObjectCache
    let externalRepresentation: CDIExternalRepresentation
    let mapping: CDIMapping
    let context: NSManagedObjectContext

    init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        self.externalRepresentation = externalRepresentation
        self.mapping = mapping
        self.context = context
        cache = CDIManagedObjectCache(externalRepresentation: externalRepresentation, mapping: mapping, context: context)
    }

    public func importAttributes() {
        // Ask cache to build cache of existing objects
        // loop over array in representation
            // ask cache if it exsists
            // if it doesn't, create it
            // update attributes
        cache.buildCacheForBaseEntity()
        let rootRepresentation = mapping.extractRootFromExternalRepresentation(externalRepresentation)

        var representationArray: CDIRepresentationArray = []
        if let array = rootRepresentation as? CDIRepresentationArray {
            representationArray = array
        }
        else if let representation = rootRepresentation as? CDIRepresentation {
            representationArray = [ representation ]
        }

        for representation in representationArray {
            var managedObject: NSManagedObject?

            // Ask the cache for the managed object
            if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {
                managedObject = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: primaryKeyValue)
            }

            // If it doesn't exist, create one and add to the cache
            if managedObject == nil {
                managedObject = mapping.createManagedObjectWithRepresentation(representation)
                if let mo = managedObject {
                    cache.addManagedObjectToCache(mo)
                }
            }

            // Update the attributes
            if let mo = managedObject {
                mapping.updateManagedObjectAttributes(mo, withRepresentation: representation)
            }
        }
    }

    public func buildRelationships() {
        // Ask cache to build cache of related objects
        // loop over array in representation
        // loop over relationships
            // ask cache if it exsists
            // if it doesn't, create it
            // update relationship
    }

}