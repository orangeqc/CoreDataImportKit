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

    /// The local managed object context to use for all operations
    let context: NSManagedObjectContext

    /// Entity description for this mapping
    let entityDescription: NSEntityDescription

    /// Attribute name which represents the primary key
    let primaryKeyAttributeName: String?

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
        primaryKeyAttributeName = entityDescription.userInfo?["relatedByAttribute"] as? String
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

        if primaryKeyAttributeName != nil {
            if let representationValue = primaryKeyValueFromRepresentation(representation) {
                object.setValue(representationValue, forKey: primaryKeyAttributeName!)
            }
        }

        return object
    }

    /**
     Creates a new managed object for the entity that the relationship points to.

     - parameter representation:   Representation where the related information should be pulled from.
     - parameter relationshipName: Name of the relationship to look up on the mapping's entity

     - returns: Returns the new managed object if created, otherwise returns nil
     */
    public func createManagedObjectWithRepresentation(representation: CDIRepresentation, forRelationship relationshipName: String) -> NSManagedObject? {

        let relationshipDescription = entityDescription.relationshipsByName[relationshipName]

        assert(relationshipDescription != nil, "Relationship \(relationshipName) does not exist")

        if let entityName = relationshipDescription?.destinationEntity?.name {

            let object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)

            // Look up the primary key and its value in the representation, then set it on the object
            if let primaryKeyAttributeName = primaryKeyAttributeNameForEntity(object.entity),
                representationValue = valueFromRepresentation(representation, forPropertyNamed: relationshipName) {

                object.setValue(representationValue, forKey: primaryKeyAttributeName)

            }

            return object
        }

        return nil
    }

    /**
     This method goes through all the attributes in the entity and updates the managed object
     if the representation includes a value for that attribute.

     - parameter managedObject:  NSManagedObject to update.
     - parameter representation: Dictionary to use to update the attributes.
     */
    public func updateManagedObjectAttributes(managedObject: NSManagedObject, withRepresentation representation: CDIRepresentation) {
        for (attributeName, attributeDescription) in entityDescription.attributesByName {
            if var representationValue: NSObject = valueInRepresentation(representation, forAttribute: attributeDescription) {

                let attributeType = attributeDescription.attributeType
                switch attributeType {
                case .DateAttributeType:
                    representationValue = dateFromRepresentationValue(representationValue, forAttribute:attributeDescription)!
                case .FloatAttributeType:
                    break
                default:
                    break
                }

                if let oldValue = managedObject.valueForKey(attributeName) where oldValue as! NSObject == representationValue {
                    continue
                }
                else {
                    managedObject.setValue(representationValue, forKey: attributeName)
                }
            }
        }
    }

    /**
     Returns the value, from the representation, of the primary key.

     - parameter representation: Representation to get the value from

     - returns: NSObject of the primary key
     */
    public func primaryKeyValueFromRepresentation(representation: CDIRepresentation) -> NSObject? {
        return valueFromRepresentation(representation, forPropertyNamed: primaryKeyAttributeName!)
    }

    /**
     Returns the value, from the representation, of the primary key for a relationship.

     - parameter representation:   The representation for the mapping's entity.
     - parameter relationshipName: Name of the relationship.

     - returns: NSObject of the primary key
     */
    public func primaryKeyValueFromRepresentation(representation: CDIRepresentation, forRelationship relationshipName: String) -> NSObject? {
        return valueFromRepresentation(representation, forPropertyNamed: relationshipName)
    }

    /**
     Returns the value, from the representation, for a given property

     - parameter representation: The representation for the mapping's entity.
     - parameter propertyName:   Name of the property to look up in the representation

     - returns: NSObject of the value
     */
    public func valueFromRepresentation(representation: CDIRepresentation, forPropertyNamed propertyName: String) -> NSObject? {
        if let property = entityDescription.propertiesByName[propertyName] {
            return valueFromRepresentation(representation, forProperty: property)
        }
        else {
            return nil
        }
    }

    /**
     Returns the value, from the representation, for a given property

     - parameter representation: The representation for the mapping's entity.
     - parameter property:       NSPropertyDescription of the property to look up the value of

     - returns: NSObject of the value
     */
    public func valueFromRepresentation(representation: CDIRepresentation, forProperty property: NSPropertyDescription) -> NSObject? {
        return representation[lookupKeyForProperty(property)]
    }


    public func primaryKeyValueForManagedObject(object: NSManagedObject) -> NSObject? {
        if let primaryKeyAttribute = primaryKeyAttributeNameForEntity(object.entity) {
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
     
     */
    public func extractRootFromExternalRepresentation(externalRepresentation: CDIExternalRepresentation) -> CDIRootRepresentation {
        return externalRepresentation;
    }

    public func represenationArrayFromExternalRepresentation(externalRepresentation: CDIExternalRepresentation) -> CDIRepresentationArray {

        let representation = extractRootFromExternalRepresentation(externalRepresentation)
        var representationArray: CDIRepresentationArray = []

        if let array = representation as? CDIRepresentationArray {
            representationArray = array
        }
        else if let representation = representation as? CDIRepresentation {
            representationArray = [ representation ]
        }

        return representationArray
    }

    /// Returns relationshipsByName from the entity description.
    public var relationshipsByName: [String : NSRelationshipDescription] {
        get {
            return entityDescription.relationshipsByName
        }
    }

    // MARK: Private Methods


    /**
    Function used to look up which key should be used to look up the value in a representation. Will 
    use `mappedKeyName` if provided, otherwise uses's the attribute's name.

    - parameter attribute: NSAttributeDescription of the attribute

    - returns: String to look up the attribute in the representation
    
    - Note: This isn't an extension on NSPropertyDescription because, at least right now, we don't
    want to leak API to other classes.
    
    - TODO: Instead of a single string, return array of possible look up keys
    */
    func lookupKeyForProperty(property: NSPropertyDescription) -> String {
        if let userInfo = property.userInfo {
            if let mappedKeyName = userInfo["mappedKeyName"] as? String {
                return mappedKeyName
            }
        }

        return property.name
    }

    /**
     Returns the attribute name used to uniquely identify a managed object

     - parameter entity: Entity to look up

     - returns: Name of the primary key attribute
     
     - Note: This isn't an extension on NSEntityDescription because, at least right now, we don't
       want to leak API to other classes.
     */
    func primaryKeyAttributeNameForEntity(entity: NSEntityDescription) -> String? {
        return entity.userInfo?["relatedByAttribute"] as? String
    }

    /**
     Returns date for a given representation and attribute. Looks up `dateFormat` in the `userInfo` or 
     uses `yyyy-MM-dd'T'HH:mm:ssz` as a default formatter.

     - parameter representationValue: Representation to extract the date string value from
     - parameter attribute:           The attribute description to look for a `dateFormat` on

     - returns: Returns a date optional
     */
    func dateFromRepresentationValue(representationValue: NSObject, forAttribute attribute:NSAttributeDescription) -> NSDate? {
        let dateFormater = NSDateFormatter()
        dateFormater.locale = NSLocale.currentLocale()
        dateFormater.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormater.dateFormat = (attribute.userInfo?["dateFormat"] as? String) ?? "yyyy-MM-dd'T'HH:mm:ssz"

        if let dateString = representationValue as? String {
            return dateFormater.dateFromString(dateString)
        }
        else {
            return nil
        }
    }

    /**
     Handles key paths for representations. Will return the value found in the representation for the attribute's lookup key.

     - parameter representation: Representation to find value in
     - parameter attribute:      Attribute description to look for mappedKeyName

     - returns: Value found at the key path
     */
    func valueInRepresentation(var representation: CDIRepresentation, forAttribute attribute:NSAttributeDescription) -> NSObject? {
        var keys = lookupKeyForProperty(attribute).componentsSeparatedByString(".")

        // Dig into each nested dictionary until there is no more
        while !keys.isEmpty, let newRep = representation[keys.first!] as? CDIRepresentation {
            keys.removeFirst()
            representation = newRep
        }

        // Check to make sure it wasn't supposed to find something deeper
        let first = keys.removeFirst()
        return keys.isEmpty ? representation[first] : nil
    }
}