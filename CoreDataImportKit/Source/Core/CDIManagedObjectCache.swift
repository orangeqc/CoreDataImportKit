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

    /// This is the cache of managed objects. The first key is the entity name. 
    /// The second key is the primary key of the managed object. The value is the managed object.
    var objectCache: [ String: [ NSObject : NSManagedObject ] ] = [:]

    /// This is the cache of primary key values. Key is the entity name. Value is a set of primary key values.
    var primaryKeyValuesCache: [String: Set<NSObject> ] = [:]

    /// The managed object context used to look up entities
    let context: NSManagedObjectContext

    /// Returns a new CDIManagedObjectCache which will use the given context
    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    /**
     Builds cache of primary keys for the representation. It will not fetch objects from the managed object context.

     - parameter externalRepresentation: Representation to for objects in
     - parameter mapping:                Mapping used to get data from the representation
     */
    public func buildCacheForExternalRepresentation(externalRepresentation: CDIExternalRepresentation, usingMapping mapping: CDIMapping) {
        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)
        for representation in representations {
            buildCacheForRepresentation(representation, usingMapping: mapping)
        }
    }

    /**
    Finds the managed object, if it exists, of the represnetation. The first time this method is called for a 
    given entity, the cache will fire a fetch for the managed objects in the managed object context.

    - parameter representation: Representation of the managed object
    - parameter mapping:        Mapping used to look up the entity information

    - returns: Managed object, if one exists
    */
    public func managedObjectForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) -> NSManagedObject? {

        let cache = objectCacheForMapping(mapping)

        if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {
            return cache[primaryKeyValue]
        }
        else {
            return nil
        }
    }

    /**
     Finds the managed object, if it exists, using the primary key. The first time this method (or
     `managedObjectForRepresentation(_:usingMapping:)` is called for a given entity, the cache will 
     fire a fetch for the managed objects in the managed object context.

     - parameter primaryKeyValue: Primay key used to look up the object
     - parameter mapping:         Mapping to find which entity to look up

     - returns: Managed object, if one exists
     */
    public func managedObjectWithPrimaryKey(primaryKeyValue: NSObject, usingMapping mapping: CDIMapping) ->  NSManagedObject? {
        let cache = objectCacheForMapping(mapping)
        return cache[primaryKeyValue]
    }


    /**

     - parameter managedObject: Object to add to the cache
     
     - Note: There is an assumption that the cache has already been initialized prior to adding this object.
     */

     /**
     Adds a managed object to the cache.

     - parameter managedObject: Object to add to the cache
     - parameter mapping:       Mapping used to look up the primary key information
     */
    public func addManagedObjectToCache(managedObject: NSManagedObject, usingMapping mapping: CDIMapping) {

        if let primaryKeyValue = mapping.primaryKeyValueForManagedObject(managedObject) {
            objectCache[mapping.entityName]?.updateValue(managedObject, forKey: primaryKeyValue)
        }

    }


    // MARK: Private Methods

    /// Builds the cache for a single representation. It will recursively look over relationships as well.
    func buildCacheForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {
        if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {

            // If the set hasn't been initialized, then create a blank set for the entity name
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
                destinationEntityMapping = mapping.mappingForRelationship(relationshipDescription),
                representationValue = mapping.valueFromRepresentation(representation, forProperty: relationshipDescription) {

                    // To-many relationship that has an array of associated objects or 
                    // to-one relationship that is nested inside the representation
                    // In both cases, we want to build the cache for the nested objects
                    if representationValue is CDIRepresentationArray || representationValue is CDIRepresentation {
                        buildCacheForExternalRepresentation(representationValue, usingMapping: destinationEntityMapping)
                    }

                    // To-one where the representation only has the foreign key
                    else {

                        // If the set hasn't been initialized, then create a blank set for the destination entity name
                        if primaryKeyValuesCache[destinationEntityName] == nil {
                            primaryKeyValuesCache[destinationEntityName] = []
                        }

                        // Add primary key to the cache
                        primaryKeyValuesCache[destinationEntityName]?.insert(representationValue)
                    }

            }
            
        }
    }

    /// Grabs the object cache for the entity defined by the mapping. If it doesn't exist yet, 
    /// then it will fetch the objects from the managed object context.
    func objectCacheForMapping(mapping: CDIMapping) -> [ NSObject : NSManagedObject ] {
        var cache = objectCache[mapping.entityName]

        if cache == nil {
            cache = fetchExistingObjectsForMapping(mapping)
            objectCache[mapping.entityName] = cache
        }

        return cache ?? [:]
    }

    /// Looks up all managed objects based on the primary keys in the cache
    func fetchExistingObjectsForMapping(mapping: CDIMapping) -> [ NSObject : NSManagedObject ] {

        let entityName = mapping.entityName

        // Make sure we have the primaryKeys and the primaryKey for the entity in question
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

            // Loop over each fetched object and put into the cache
            for object in existingObjects as! [NSManagedObject] {

                if let primaryKeyValue = mapping.primaryKeyValueForManagedObject(object) {
                    cache[primaryKeyValue] = object
                }

            }

        }
        catch {
            print("Failed to fetch objects for \(entityName).")
        }

        return cache
    }

}