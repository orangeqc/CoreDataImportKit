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

    /// Cache the import uses to pre-fetch managed objects
    let cache: CDIManagedObjectCache

    /// Representation that the import will import
    let externalRepresentation: CDIExternalRepresentation

    /// User given mapping which will define how to get data from the external representation
    let baseMapping: CDIMapping

    /// Managed object context to find/create objects within
    let context: NSManagedObjectContext

    /**
     Creates a new CDIImport. This will create and build information for cache. It does not fetch any data from context.

     - parameter externalRepresentation: Representation of the data to be imported
     - parameter mapping:                Mapping which describes how to get data from the representation
     - parameter context:                Managed object context to find/create objects within

     - returns: Instance of CDIImport
     */
    public init(externalRepresentation: CDIExternalRepresentation, mapping: CDIMapping, context: NSManagedObjectContext) {
        self.externalRepresentation = externalRepresentation
        self.baseMapping = mapping
        self.context = context
        cache = CDIManagedObjectCache(context: context)
        cache.buildCacheForExternalRepresentation(externalRepresentation, usingMapping: mapping)
    }

    /// Imports attributes and builds relationships for the represetnation
    public func importRepresentation() {
        importAttributes()
        buildRelationships()
    }

    /// Imports attributes for the representation. This will not build relationships.
    public func importAttributes() {

        let representations = baseMapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            importAttributesForRepresentation(representation, usingMapping: baseMapping)
        }

    }

    /// Builds the relationships for the representation. Can only be used after importing attributes.
    public func buildRelationships() {

        let representations = baseMapping.represenationArrayFromExternalRepresentation(externalRepresentation)

        for representation in representations {
            buildRelationshipsForRepresentation(representation, usingMapping: baseMapping)
        }

    }

     /**
     Imports the attributes for the representation. Looks up the object in the cache and creates one if it is missing.

     - parameter representation: Representation to import
     - parameter mapping:        Mapping used to get the data from the representation
     */
    func importAttributesForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {

        // Ask the cache for the managed object
        var managedObjectOptional = cache.managedObjectForRepresentation(representation, usingMapping: mapping)

        // If it doesn't exist, create one and add it to the cache
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
     Builds the relationships for the representation. If any relationship is nested in the representation,
     their attributes and relationships will be imported. 
     
     If the managed object represented by the top level of the representation hasn't been imported this method
     will do nothing.

     - parameter representation: Representation of the object to build relationships of.
     - parameter mapping:        Mapping which will be used to find the relationships in the representation.
     */
    func buildRelationshipsForRepresentation(representation: CDIRepresentation, usingMapping mapping: CDIMapping) {

        // Ask the cache for the managed object, do nothing if it isn't found
        guard let managedObject = cache.managedObjectForRepresentation(representation, usingMapping: mapping) else {
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

            let shouldBuildRelationship = (managedObject as CDIManagedObjectProtocol).shouldBuildRelationship?(relationshipName, withRelationshipRepresentation: representationValue, fromRepresentation: representation) ?? true
            if shouldBuildRelationship == false {
                continue
            }

            // To-many relationship that has an array of associated objects
            if let representationArray = representationValue as? CDIRepresentationArray {
                for relationshipRepresentation in representationArray {

                    // Import / build the representation (this is recursive)
                    importAttributesForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping)
                    buildRelationshipsForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping)

                    // Build the to-many relationship on the managedObject
                    if let relatedManagedObject = cache.managedObjectForRepresentation(relationshipRepresentation, usingMapping: destinationEntityMapping) {
                        managedObject.mutableSetValueForKey(relationshipName).addObject(relatedManagedObject)
                    }

                }
            }

            // To-one relationship that is nested inside the representation
            else if let singleRepresentation = representationValue as? CDIRepresentation {

                // Import / build the representation (this is recursive)
                importAttributesForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping)
                buildRelationshipsForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping)

                // Build the to-one relationship on the managedObject
                if let relatedManagedObject = cache.managedObjectForRepresentation(singleRepresentation, usingMapping: destinationEntityMapping) {
                    managedObject.setValue(relatedManagedObject, forKey: relationshipName)
                }

            }

            // To-one relationship where we only have the value of the foreign key
            else {

                // Ask cache for existing object
                var relatedManagedObject = cache.managedObjectWithPrimaryKey(representationValue, usingMapping: destinationEntityMapping)

                // If it does not exist, create it, and set the primary key
                if relatedManagedObject == nil {
                    relatedManagedObject = destinationEntityMapping.createManagedObjectWithPrimaryKey(representationValue)
                }

                // Build the relationship
                managedObject.setValue(relatedManagedObject!, forKey: relationshipName)
            }
        }

        (managedObject as CDIManagedObjectProtocol).didImport?(representation)
    }

}