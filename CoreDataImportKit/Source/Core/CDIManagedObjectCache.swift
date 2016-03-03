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

    /// This is the cache of primary key values. Key is the entity name. Value is a set of primary key values.
    var primaryKeyValuesCache: [String: Set<NSObject> ] = [:]

    /// The managed object context used to look up entities
    let context: NSManagedObjectContext

    /**
     Initialize a CDIManagedObjectCache

     - parameter externalRepresentation: External representation used to look up objects to cache.
     - parameter mapping:                Mapping to use to extract data from the representation.
     - parameter context:                Managed object context in which to look objects up.

     - returns: CDIManagedObjectCache
     */
    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func buildCacheForExternalRepresentation(externalRepresentation: CDIExternalRepresentation, usingMapping mapping: CDIMapping) {
        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)
        for representation in representations {
            buildCacheForRepresentation(representation, usingMapping: mapping)
        }
    }

    func buildCacheForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {
        if let primaryKeyAttributeName = mapping.primaryKeyAttributeName,
            primaryKeyValue = mapping.valueFromRepresentation(representation, forPropertyNamed: primaryKeyAttributeName) {

            // If the set hasn't been set, then set a blank set
            if primaryKeyValuesCache[mapping.entityName] == nil {
                primaryKeyValuesCache[mapping.entityName] = []
            }

            // Add primary key to the cache
            primaryKeyValuesCache[mapping.entityName]?.insert(primaryKeyValue);
        }

        // Loop over each relationship
        for (_, relationshipDescription) in mapping.relationshipsByName {

            if let entity = relationshipDescription.destinationEntity,
                destinationEntityName = entity.name,
                representationValue = mapping.valueFromRepresentation(representation, forProperty: relationshipDescription),
                destinationEntityMapping = mapping.mappingForRelationship(relationshipDescription) {

                    // To-many relationship that has an array of associated objects
                    if let representationArray = representationValue as? CDIRepresentationArray {
                        buildCacheForExternalRepresentation(representationArray, usingMapping: destinationEntityMapping)
                    }
                    // To-one that is nested inside the representation
                    else if let singleRepresentation = representationValue as? CDIRepresentation {
                        buildCacheForExternalRepresentation(singleRepresentation, usingMapping: destinationEntityMapping)
                    }
                    // Just has a foreign key as a part of the representation
                    else {
                        if primaryKeyValuesCache[destinationEntityName] == nil {
                            primaryKeyValuesCache[destinationEntityName] = []
                        }
                        primaryKeyValuesCache[destinationEntityName]?.insert(representationValue)
                    }
            }

        }
    }

    /// Checks to see if a managed object has been cached already. Should to an internal validation check to make sure that building the cache has happened already.
    public func managedObjectForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) -> NSManagedObject? {

        let cache = objectCacheForMapping(mapping)

        if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {
            return cache[primaryKeyValue]
        }
        else {
            return nil
        }
    }

    public func managedObjectForPrimaryKey(primaryKeyValue: NSObject, usingMapping mapping: CDIMapping) ->  NSManagedObject? {
        let cache = objectCacheForMapping(mapping)
        return cache[primaryKeyValue]
    }

    public func objectCacheForMapping(mapping: CDIMapping) -> [ NSObject : NSManagedObject ] {
        var cache = objectCache[mapping.entityName]

        if cache == nil {
            cache = fetchExistingObjectsForMapping(mapping)
            objectCache[mapping.entityName] = cache
        }

        return cache ?? [:] // could also do cache!
    }

    /**
     Adds a managed object to the cache.
     
     There is an assumption that the cache has already been initialized prior to adding this object.

     - parameter managedObject: Object to add to the cache
     */
    public func addManagedObjectToCache(managedObject: NSManagedObject, usingMapping mapping: CDIMapping) {
        if let entityName = managedObject.entity.name,
            primaryKeyValue = mapping.primaryKeyValueForManagedObject(managedObject) {

            objectCache[entityName]?.updateValue(managedObject, forKey: primaryKeyValue)
        }
    }

    public func resetCache() {
        primaryKeyValuesCache = [:]
        objectCache = [:]
    }

    // MARK: Private Methods

    /// Looks up all managed objects based on the primary keys in the cache
    func fetchExistingObjectsForMapping(mapping: CDIMapping) -> [ NSObject : NSManagedObject ] {
        // Make sure we have the primaryKeys and the primaryKey for the entity in question
        let entityName = mapping.entityName
        guard let primaryKeys = primaryKeyValuesCache[entityName], primaryKeyAttributeName = mapping.primaryKeyAttributeName else {
            return [:]
        }

        var cache: [ NSObject : NSManagedObject ] = [:]

        // Build fetch request
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "%K in %@", primaryKeyAttributeName, primaryKeys);
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = primaryKeys.count

        // Execute the fetch request and update the object cache
        do {
            let existingObjects = try context.executeFetchRequest(fetchRequest)
            for object in existingObjects as! [NSManagedObject] {
                if let primaryKeyValue = object.valueForKey(primaryKeyAttributeName) as? NSObject {
                    cache[primaryKeyValue] = object
                }
                else {
                    print("Object imported for \(entityName) doesn't have a primary key set")
                }
            }
        }
        catch {
            print("Failed to fetch objects.")
        }

        return cache
    }

}