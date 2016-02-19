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
    var objectCache: [ String: [ Int : NSManagedObject ] ]

    /// `primaryKeyCache[entityName] = primaryKeyAttribute`
    var primaryKeyCache: [ String: String ]

    // TODO: It should be a set since they should be unique values to keep memory impact low. But is there any way to get away from NSObject?
    var primaryKeysCache: [String: Set<NSObject> ]

    let externalRepresentation: CDIExternalRepresentation
    let mapping: CDIMapping
    let context: NSManagedObjectContext

    init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        objectCache = [:]
        primaryKeyCache = [:]
        primaryKeysCache = [:]
        self.externalRepresentation = externalRepresentation
        self.mapping = mapping
        self.context = context
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
        fetchExistingObjectsForEntity(mapping.entityName)
    }

    public func buildCacheForRelatedEntities() {
        let rootRepresentation = mapping.extractRootFromExternalRepresentation(externalRepresentation)

        var representationArray: CDIRepresentationArray = []
        if let array = rootRepresentation as? CDIRepresentationArray {
            representationArray = array
        }
        else if let representation = rootRepresentation as? CDIRepresentation {
            representationArray = [ representation ]
        }

        // Build base values and set primaryKeyCache
        for relationshipDescription in mapping.relationshipsByName.values {
            if let entity = relationshipDescription.destinationEntity {
                if let primaryKeyAttribute = mapping.primaryKeyAttributeForEntity(entity), entityName = entity.name {

                    // This is the attribute we'll use to look up the managed object later
                    primaryKeyCache[entityName] = primaryKeyAttribute

                    // Setting an empty set for the primary keys that will be collected next
                    primaryKeysCache[entityName] = []

                }
            }
        }

        for representation in representationArray {
            for (relationship, relationshipDescription) in mapping.relationshipsByName {
                if let entity = relationshipDescription.destinationEntity,
                    entityName = entity.name,
                    primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation, forRelationship: relationship) {

                    // Add the primary key value to the cache
                    primaryKeysCache[entityName]?.insert(primaryKeyValue)

                }
            }
        }

        // Now loop over relationships to look up the managed objects
        for relationshipDescription in mapping.relationshipsByName.values {
            if let entity = relationshipDescription.destinationEntity,
                entityName = entity.name {
                    fetchExistingObjectsForEntity(entityName)
            }
        }
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
            primaryKeysCache[mapping.entityName]?.insert(primaryKey);
        }
    }

    // TODO: Fetch based on entity name
    func fetchExistingObjectsForEntity(entityName: String) {
        // Make sure we have the primaryKeys and the primaryKey for the entity in question
        guard let primaryKeys = primaryKeysCache[entityName], let primaryKey = primaryKeyCache[entityName] else {
            return
        }

        // Set the base value for the entity name
        if objectCache.indexForKey(entityName) == nil {
            objectCache[entityName] = [:]
        }

        // Build fetch request
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "%K in %@", primaryKey, primaryKeys);
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = primaryKeys.count

        // Execute the fetch request and update the object cache
        do {
            let existingObjects = try context.executeFetchRequest(fetchRequest)
            for object in existingObjects {
                let primaryKeyForObject = object.valueForKey(primaryKey) as! Int
                objectCache[entityName]?.updateValue(object as! NSManagedObject, forKey: primaryKeyForObject)
            }
        }
        catch {
            print("Failed to fetch objects.")
        }
    }
}