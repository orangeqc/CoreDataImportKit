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

    /// This is the cache of objects. The first key is the class name. The second key is the primary key. The value is the managed object.
    var objectCache: [ String: [ NSObject : NSManagedObject ] ] = [:]

    /// This is a cache of attribute names which represent primary keys. Key is the entity name. Value is the primary key attribute's name.
    var primaryKeyAttributeNameCache: [ String: String ] = [:]

    /// This is the cache of primary key values. Key is the entity name. Value is a set of primary key values.
    var primaryKeyValuesCache: [String: Set<NSObject> ] = [:]

    /// The representation data that this cache will work with.
    let externalRepresentation: CDIExternalRepresentation

    /// The mapping that should be used to pull data out of the representation.
    let mapping: CDIMapping

    /// The managed object context used to look up entities
    let context: NSManagedObjectContext

    /**
     Initialize a CDIManagedObjectCache

     - parameter externalRepresentation: External representation used to look up objects to cache.
     - parameter mapping:                Mapping to use to extract data from the representation.
     - parameter context:                Managed object context in which to look objects up.

     - returns: CDIManagedObjectCache
     */
    init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        self.externalRepresentation = externalRepresentation
        self.mapping = mapping
        self.context = context
    }

    /**
     Builds the cache for the main entity in the representation.
     */
    public func buildCacheForBaseEntity() {
        resetCacheForBaseEntity()

        // Build up the cache of primary keys for each representation
        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)
        for representation in representations {
            buildPrimaryKeysCacheWithRepresentation(representation)
        }

        // Fetch all entities from CoreData
        fetchExistingObjectsForEntity(mapping.entityName)
    }

    /**
     Builds the cache for the related entities.
     */
    public func buildCacheForRelatedEntities() {
        resetCacheForRelationships()

        // Add the primary key value for each relationship
        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)
        for representation in representations {
            buildPrimaryKeysCacheForRelationshipsWithRepresentation(representation)
        }

        fetchExistingObjectsForRelationships()
    }

    /// Checks to see if a managed object has been cached already. Should to an internal validation check to make sure that building the cache has happened already.
    public func managedObjectForEntity(entityName: String, primaryKeyValue: NSObject) -> NSManagedObject? {
        return objectCache[entityName]?[primaryKeyValue];
    }

    /**
     Adds a managed object to the cache.
     
     There is an assumption that the cache has already been initialized prior to adding this object.

     - parameter managedObject: Object to add to the cache
     */
    public func addManagedObjectToCache(managedObject: NSManagedObject) {
        if let entityName = managedObject.entity.name,
            primaryKeyValue = mapping.primaryKeyValueForManagedObject(managedObject) {

            objectCache[entityName]?.updateValue(managedObject, forKey: primaryKeyValue)

        }
    }

    // MARK: Private Methods

    // Resets the caches for the base entity
    func resetCacheForBaseEntity() {
        primaryKeyAttributeNameCache[mapping.entityName] = mapping.primaryKeyAttributeName!
        primaryKeyValuesCache[mapping.entityName] = []
    }

    /// Set primary key attribute name for each relationship and initialize the primary keys value cache
    func resetCacheForRelationships() {
        for relationshipDescription in mapping.relationshipsByName.values {

            if let entity = relationshipDescription.destinationEntity,
                primaryKeyAttributeName = mapping.primaryKeyAttributeNameForEntity(entity),
                entityName = entity.name {

                    primaryKeyAttributeNameCache[entityName] = primaryKeyAttributeName
                    primaryKeyValuesCache[entityName] = []

            }
        }
    }

    /// Adds the representation's primary key to the cache
    func buildPrimaryKeysCacheWithRepresentation(representation: CDIRepresentation) {

        // Add the primary key to the cache
        if let primaryKey = mapping.primaryKeyValueFromRepresentation(representation) {
            primaryKeyValuesCache[mapping.entityName]?.insert(primaryKey);
        }

    }

    /// Adds the primary keys for the entity's relationships, using the values in the representation
    func buildPrimaryKeysCacheForRelationshipsWithRepresentation(representation: CDIRepresentation) {
        // Loop over each relationship
        for (relationship, relationshipDescription) in mapping.relationshipsByName {

            if let entity = relationshipDescription.destinationEntity,
                entityName = entity.name,
                primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation, forRelationship: relationship) {

                    // Add the primary key value to the cache
                    primaryKeyValuesCache[entityName]?.insert(primaryKeyValue)
                    
            }
        }
    }

    /// Looks up all managed objects based on the primary keys in the cache
    func fetchExistingObjectsForEntity(entityName: String) {
        // Make sure we have the primaryKeys and the primaryKey for the entity in question
        guard let primaryKeys = primaryKeyValuesCache[entityName], let primaryKey = primaryKeyAttributeNameCache[entityName] else {
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
                let primaryKeyForObject = object.valueForKey(primaryKey) as! NSObject
                objectCache[entityName]?.updateValue(object as! NSManagedObject, forKey: primaryKeyForObject)
            }
        }
        catch {
            print("Failed to fetch objects.")
        }
    }

    /// Loop over each relationship to look up the managed objects
    func fetchExistingObjectsForRelationships() {
        for relationshipDescription in mapping.relationshipsByName.values {

            if let entity = relationshipDescription.destinationEntity,
                entityName = entity.name {

                    fetchExistingObjectsForEntity(entityName)

            }
        }
    }
}