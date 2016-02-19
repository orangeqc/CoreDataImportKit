//
//  CDIMapping.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/11/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

public class CDIMapping {
    /// The `entityName` that this mapping represents
    public let entityName: String

    /// Boolean value which specifies if the entity has a primary key defined.
    public var hasPrimaryKey: Bool {
        get {
            return primaryKey != nil
        }
    }

    /// The local managed object context to use for all operations
    let context: NSManagedObjectContext

    /// Entity description for this mapping
    let entityDescription: NSEntityDescription

    /// Attribute name which represents the primary key
    let primaryKey: String?

    /**
     Initializes as mapping for a given entity inside a given context.

     - parameter entityName: Name of the entity which this mapping represents
     - parameter context:    NSManagedObjectContext in which to look the entity up

     - returns: Returns a mapping
     */
    init(entityName: String, inManagedObjectContext context: NSManagedObjectContext) {
        self.entityName = entityName
        self.context = context

        let description = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        assert(description != nil)
        entityDescription = description!

        // TODO: figure out why I can't use `primaryKeyAttributeForEntity(entityDescription)` here
        primaryKey = entityDescription.userInfo?["relatedByAttribute"] as? String
    }

    /**
     Creates a new managed object based on this mapping's entity. It will only set the primary key, if
     the primary key is defined and is in the representation. 
     
     Note: This does not save the context, you are responsible for that.

     - parameter representation: Dictionary representing a single managed object.

     - returns: Returns the newly created managed object.
     */
    public func createManagedObjectWithRepresentation(representation: CDIRepresentation) -> NSManagedObject {

        let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)

        if primaryKey != nil {
            if let representationValue = primaryKeyValueFromRepresentation(representation) {
                object.setValue(representationValue, forKey: primaryKey!)
            }
        }

        return object
    }

    /**
     This method goes through all the attributes in the entity and updates the managed object
     if the representation includes a value for that attribute.

     - parameter managedObject:  NSManagedObject to update.
     - parameter representation: Dictionary to use to update the attributes.
     */
    public func updateManagedObjectAttributes(managedObject: NSManagedObject, withRepresentation representation: [ String : AnyObject ]) {
        for (attributeName, attributeDescription) in entityDescription.attributesByName {
            if let representationValue = representation[lookupKeyForProperty(attributeDescription)] {
                // TODO: Only set value if they are actually different
                managedObject.setValue(representationValue, forKey: attributeName)
            }
        }
    }

    public func primaryKeyValueFromRepresentation(representation: CDIRepresentation) -> NSObject? {
        if let attribute = entityDescription.attributesByName[primaryKey!] {
            return representation[lookupKeyForProperty(attribute)]
        }
        else {
            return nil
        }
    }

    public func primaryKeyValueFromRepresentation(representation: CDIRepresentation, forRelationship relationshipName: String) -> NSObject? {
        if let relationship = entityDescription.relationshipsByName[relationshipName] {
            return representation[lookupKeyForProperty(relationship)]
        }
        else {
            return nil
        }
    }

    public func primaryKeyValueForManagedObject(object: NSManagedObject) -> NSObject? {
        if let primaryKeyAttribute = primaryKeyAttributeForEntity(object.entity) {
            return object.valueForKey(primaryKeyAttribute) as? NSObject
        }
        else {
            return nil
        }
    }

    /**
     Returns an array of dictionaries which represent objects to be imported. 
     This method returns what it is given. It is intended to be overwritten by 
     subclasses if they need to extract data from a more complex representation.

     - parameter externalRepresentation: External representation

     - returns: Array of dictionaries which represent objects.
     
     Todo: Probably needs to take an AnyObject so that subclasses can modify the AnyObject into
     the required array. Example: if you wanted to do a mapping subclass which handled 
     JSONAPI this is where you'd overwrite how to extract the proper array.
     */
    public func extractRootFromExternalRepresentation(externalRepresentation: CDIExternalRepresentation) -> CDIRootRepresentation {
        return externalRepresentation;
    }

    public var relationshipsByName: [String : NSRelationshipDescription] {
        get {
            return entityDescription.relationshipsByName
        }
    }

    // MARK: Private Methods


    /**
    Function used to look up which key should be used to look up the value in a representation.

    - parameter attribute: NSAttributeDescription of the attribute

    - returns: String to look up the attribute in the representation
    */
    // TODO: Instead of a single string, return array of possible look up keys
    func lookupKeyForProperty(property: NSPropertyDescription) -> String {
        if let userInfo = property.userInfo {
            if let mappedKeyName = userInfo["mappedKeyName"] as? String {
                return mappedKeyName
            }
        }

        return property.name
    }

    func primaryKeyAttributeForEntity(entity: NSEntityDescription) -> String? {
        return entity.userInfo?["relatedByAttribute"] as? String
    }
}