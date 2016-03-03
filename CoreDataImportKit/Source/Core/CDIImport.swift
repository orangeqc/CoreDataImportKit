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
    let baseMapping: CDIMapping

    /// Managed object context to find existing objects and to create new ones
    let context: NSManagedObjectContext

    public init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        self.externalRepresentation = externalRepresentation
        self.baseMapping = mapping
        self.context = context
        cache = CDIManagedObjectCache(context: context)
        cache.buildCacheForExternalRepresentation(externalRepresentation, usingMapping: mapping)
    }

    public func importRepresentation() {
        importAttributes()
        buildRelationships()
    }

    /**
     Imports all the attributes for the mapping's base entity
     */
    public func importAttributes() {

        let representations = baseMapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            importAttributesForRepresentation(representation, usingMapping: baseMapping)
        }

    }

    /**
     Builds all the relationships. The assumption is the base entities are already in the cache.
     */
    public func buildRelationships() {

        let representations = baseMapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            importRelationshipsForRepresentation(representation, usingMapping: baseMapping)
        }

    }

    /**
     Imports the attributes for the representation. Looks up the object in the cache and creates one if it is missing.

     - parameter representation: Representation to import.
     */
    public func importAttributesForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {

        // Ask the cache for the managed object
        var managedObjectOptional = cache.managedObjectForRepresentation(representation, usingMapping: mapping)

        // If it doesn't exist, create one and add to the cache
        // TODO: Add option to skip the creation
        if managedObjectOptional == nil {
            managedObjectOptional = mapping.createManagedObjectWithRepresentation(representation)
            if let managedObject = managedObjectOptional {
                cache.addManagedObjectToCache(managedObject, usingMapping: mapping)
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
    public func importRelationshipsForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {
        // Ask the cache for the managed object
        guard let managedObject = cache.managedObjectForRepresentation(representation, usingMapping: mapping) else {
            print("Issue with finding the managed object when building relationships.")
            return
        }

        // Build relationships for the managed object
        for (relationshipName, relationshipDescription) in mapping.relationshipsByName {

            guard let destinationEntityMapping = mapping.mappingForRelationship(relationshipDescription) else {
                print("Related entity has no entity name. Relationship name: \(relationshipName)")
                continue
            }
            guard let representationValue = mapping.valueFromRepresentation(representation, forProperty: relationshipDescription) else {
                // In this case the representation has no value for the relationship. We can go to the next relationship.
                continue
            }

            // To-many relationship that has an array of associated objects
            if let representationArray = representationValue as? CDIRepresentationArray {
                for relationshipRepresentation in representationArray {

                    importAttributesForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping)
                    importRelationshipsForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping)

                    if let relatedManagedObject = cache.managedObjectForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping) {
                        managedObject.mutableSetValueForKey(relationshipName).addObject(relatedManagedObject)
                    }

                }
            }
                // To-one that is nested inside the representation
            else if let singleRepresentation = representationValue as? CDIRepresentation {
                importAttributesForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping)
                importRelationshipsForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping)
                if let relatedManagedObject = cache.managedObjectForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping) {
                    managedObject.setValue(relatedManagedObject, forKey: relationshipName)
                }
            }
                // Just has a foreign key as a part of the representation
            else {
                var relatedManagedObject = cache.managedObjectForPrimaryKey(representationValue, usingMapping: destinationEntityMapping)

                if relatedManagedObject == nil {
                    relatedManagedObject = destinationEntityMapping.createManagedObjectWithPrimaryKey(representationValue)
                }

                managedObject.setValue(relatedManagedObject!, forKey: relationshipName)
            }
        }

        (managedObject as CDIManagedObjectProtocol).didImport?(representation)
    }

}