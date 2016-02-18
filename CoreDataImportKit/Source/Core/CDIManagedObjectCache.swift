//
//  CDIManagedObjectCache.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/16/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

public class CDIManagedObjectCache {

    /// `objectCache[entityName][primaryKeyValue] = entity`
    var objectCache: [ String: AnyObject ]

    /// `primaryKeyCache[entityName] = primaryKeyAttribute`
    var primaryKeyCache: [ String: String ]

    var primaryKeysCache: [String: [ AnyObject ]]

    let externalRepresentation: CDIExternalRepresentation
    let mapping: CDIMapping

    init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping) {
        objectCache = [:]
        primaryKeyCache = [:]
        primaryKeysCache = [:]
        self.externalRepresentation = externalRepresentation
        self.mapping = mapping
    }

    public func buildCacheForBaseEntity() {
        let rootRepresentation = mapping.extractRootFromExternalRepresentation(externalRepresentation)
        if let representationArray = rootRepresentation as? CDIRepresentationArray {
            for representation in representationArray {
                buildPrimaryKeysCacheWithRepresentation(representation)
            }
        }
        else if let representation = rootRepresentation as? CDIRepresentation {
            buildPrimaryKeysCacheWithRepresentation(representation)
        }

        if primaryKeyCache.indexForKey(mapping.entityName) == nil && mapping.hasPrimaryKey {
            primaryKeyCache[mapping.entityName] = mapping.primaryKey!
        }

        // Fetch all entities from CD
    }

    public func buildCacheForRelatedEntities() {
        // TODO: needs work
        // ask mapping for root of representation
        // inspect each object in rep. and ask mapping for each relationship
        // loop over each and inspect it (get primary key)
        //    get entity mapping from base mapping, given relationship
        // fetch all existing objects using primary keys for relationships
    }

    /// Checks to see if a managed object has been cached already. Should to an internal validation check to make sure that building the cache has happened already.
    public func managedObjectExistsForRepresentation(representation: CDIRepresentation, mapping: CDIMapping) -> Bool {
        return false;
    }

    public func addManagedObject(managedObject: NSManagedObject, mapping: CDIMapping) {

    }

    // MARK: Private Methods

    func buildPrimaryKeysCacheWithRepresentation(representation: CDIRepresentation) {
        if primaryKeysCache.indexForKey(mapping.entityName) == nil {
            primaryKeysCache[mapping.entityName] = []
        }

        if let primaryKey = mapping.primaryKeyValueFromRepresentation(representation) {
            primaryKeysCache[mapping.entityName]?.append(primaryKey);
        }
    }

}