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

    /// Cache the import uses to speed the lookups
    let cache: CDIManagedObjectCache

    /// Representation that the import will use
    let externalRepresentation: CDIExternalRepresentation

    /// User given mapping which will define how to get data from the representation
    let mapping: CDIMapping

    /// Managed object context to find existing objects and to create new ones
    let context: NSManagedObjectContext

    init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        self.externalRepresentation = externalRepresentation
        self.mapping = mapping
        self.context = context
        cache = CDIManagedObjectCache(externalRepresentation: externalRepresentation, mapping: mapping, context: context)
    }

    /**
     Imports all the attributes for the mapping's base entity
     */
    public func importAttributes() {

        cache.buildCacheForBaseEntity()

        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            importAttributesForRepresentation(representation)
        }

    }

    /**
     Builds all the relationships. The assumption is the base entities are already in the cache.
     */
    public func buildRelationships() {

        cache.buildCacheForRelatedEntities()

        let representations = mapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            importRelationshipsForRepresentation(representation)
        }

    }

    /**
     Imports the attributes for the representation. Looks up the object in the cache and creates one if it is missing.

     - parameter representation: Representation to import.
     */
    public func importAttributesForRepresentation(representation: CDIRepresentation) {
        var managedObjectOptional: NSManagedObject?

        // Ask the cache for the managed object
        if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {
            managedObjectOptional = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: primaryKeyValue)
        }

        // If it doesn't exist, create one and add to the cache
        // TODO: Add option to skip the creation
        if managedObjectOptional == nil {
            managedObjectOptional = mapping.createManagedObjectWithRepresentation(representation)
            if let managedObject = managedObjectOptional {
                cache.addManagedObjectToCache(managedObject)
            }
        }

        // Update the attributes
        if let managedObject = managedObjectOptional {

            let shouldImport = (managedObject as CDIManagedObjectProtocol).shouldImport?(representation) ?? true

            if shouldImport {

                (managedObject as CDIManagedObjectProtocol).willImport?(representation)

                mapping.updateManagedObjectAttributes(managedObject, withRepresentation: representation)
            }
        }
    }

    /**
     Imports the relationships for the representation.

     - parameter representation: Representation for the import
     */
    public func importRelationshipsForRepresentation(representation: CDIRepresentation) {
        var managedObjectOptional: NSManagedObject?

        // Ask the cache for the managed object
        if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation) {
            managedObjectOptional = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: primaryKeyValue)
        }

        guard let managedObject = managedObjectOptional else {
            print("Issue with finding the managed object when building relationships.")
            return
        }

        // Build relationships for the managed object
        for (relationship, relationshipDescription) in mapping.relationshipsByName {

            guard let relatedEntityName = relationshipDescription.destinationEntity?.name else {
                print("Related entity has no entity name")
                continue
            }

            var relatedManagedObjectOptional: NSManagedObject?

            // Ask the cache for the managed object
            if let primaryKeyValue = mapping.primaryKeyValueFromRepresentation(representation, forRelationship: relationship) {
                relatedManagedObjectOptional = cache.managedObjectForEntity(relatedEntityName, primaryKeyValue: primaryKeyValue)
            }

            // If it doesn't exist, create one and add to the cache
            // TODO: Add option to skip creation of relationships
            if relatedManagedObjectOptional == nil {
                relatedManagedObjectOptional = mapping.createManagedObjectWithRepresentation(representation, forRelationship: relationship)
                if let relatedManagedObject = relatedManagedObjectOptional {
                    cache.addManagedObjectToCache(relatedManagedObject)
                }
            }

            let shouldBuild = (managedObject as CDIManagedObjectProtocol).shouldBuildRelationship?(relationship, withRepresentation: representation) ?? true

            if shouldBuild {
                // Update relationship
                if let relatedManagedObject = relatedManagedObjectOptional {
                    managedObject.setValue(relatedManagedObject, forKey: relationship)
                }
            }
        }

        (managedObject as CDIManagedObjectProtocol).didImport?(representation)
    }
}