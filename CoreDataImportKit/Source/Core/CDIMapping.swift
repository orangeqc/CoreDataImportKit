//
//  CDIMapping.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/11/16.
//  Copyright © 2016 OrangeQC. All rights reserved.


import Foundation
import CoreData

open class CDIMapping {

    /// The entity name that this mapping represents
    open let entityName: String

    /// The local managed object context to use for all core data operations
    let context: NSManagedObjectContext

    /// Entity description for this mapping
    let entityDescription: NSEntityDescription

    /// Attribute name which represents the primary key
    let primaryKeyAttributeName: String?

    /**
     Initializes a mapping for a given entity inside a given context.

     - parameter entityName: Name of the entity which this mapping represents
     - parameter context:    NSManagedObjectContext in which to look the entity up

     - returns: Instance of CDIMapping
     */
    public init(entityName: String, inManagedObjectContext context: NSManagedObjectContext) {
        self.entityName = entityName
        self.context = context

        let description = NSEntityDescription.entity(forEntityName: entityName, in: context)

        assert(description != nil)

        entityDescription = description!

        primaryKeyAttributeName = entityDescription.userInfo?["relatedByAttribute"] as? String
    }

    /// Creates a new mapping to represent the entity defined by the relationship
    open func mappingForRelationship(_ relationship: NSRelationshipDescription) -> CDIMapping? {
        guard let name = relationship.destinationEntity?.name else {
            assertionFailure("\(relationship) has no destination entity")
            return nil
        }

        if entityName == name {
            return self
        }
        else {
            return CDIMapping(entityName: name, inManagedObjectContext: context)
        }
    }

    /**
     Creates a new managed object based on this mapping's entity. If the primary key is defined and
     is in the representation then it will set the primary key.

     Note: This does not save the managed object context, you are responsible for that

     - parameter representation: CDIRepresentation representing a managed object

     - returns: Newly created managed object
     */
    open func createManagedObjectWithRepresentation(_ representation: CDIRepresentation) -> NSManagedObject {

        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)

        if let primaryKeyAttributeName = primaryKeyAttributeName,
            let representationValue = primaryKeyValueFromRepresentation(representation) {

            if let value: NSObject = representationValue as? NSObject {
                object.setValue(value, forKey: primaryKeyAttributeName)
            }

        }

        return object
    }


    /**
     Creates a new managed object based on this mapping's entity and sets the primary key.

     Note: This does not save the managed object context, you are responsible for that

     - parameter primaryKey: Primary key to set on new entity.

     - returns: Newly created managed object
     */
    open func createManagedObjectWithPrimaryKey(_ primaryKey: NSObject) -> NSManagedObject {

        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)

        if let primaryKeyAttributeName = primaryKeyAttributeName {
            object.setValue(primaryKey, forKey: primaryKeyAttributeName)
        }

        return object
    }

    /**
     This method goes through all the attributes in the entity and updates the managed object
     if the representation includes a value for that attribute.

     - parameter managedObject:  NSManagedObject to update.
     - parameter representation: Dictionary to use to update the attributes.
     */
    open func updateManagedObjectAttributes(_ managedObject: NSManagedObject, withRepresentation representation: CDIRepresentation) {

        for (attributeName, attributeDescription) in entityDescription.attributesByName {


            // Grab the value from the representation
            if var representationValue: NSObject = valueFromRepresentation(representation, forProperty: attributeDescription) as! NSObject? {

                let attributeType = attributeDescription.attributeType

                // Modify the representationValue based on the attribute type
                // TODO: Move to seperate method
                // TODO: Change to switch statement
                // TODO: Support all attribute types
                // This is based on NSAttributeDescription+MagicalDataImport's
                // MR_valueForKeyPath:fromObjectData:
                if attributeType == .dateAttributeType {
                    representationValue = dateFromRepresentationValue(representationValue, forAttribute:attributeDescription)! as NSDate
                }
                else if attributeType == .stringAttributeType &&
                    representationValue.isKind(of: NSString.self) == false &&
                    representationValue.isKind(of: NSNull.self) == false {
                    representationValue = NSString(string: representationValue.description)
                }

                // Only set the new value if it is different from the old value
                if let oldValue = managedObject.value(forKey: attributeName) , oldValue as! NSObject == representationValue {
                    continue
                }
                else {

                    let shouldImportAttribute = (managedObject as CDIManagedObjectProtocol).shouldImportAttribute?(attributeName, withData: representationValue, inRepresentation: representation) ?? true

                    if (shouldImportAttribute) {
                        managedObject.setValue(representationValue, forKey: attributeName)
                    }

                }
            }
        }
    }

    /**
     Returns the value, from the representation, of the primary key.

     - parameter representation: Representation to get the value from

     - returns: NSObject of the primary key
     */
    open func primaryKeyValueFromRepresentation(_ representation: CDIRepresentation) -> Any? {
        return valueFromRepresentation(representation, forPropertyNamed: primaryKeyAttributeName!)
    }

    /**
     Returns the value, from the representation, for a given property

     - parameter representation: The representation for the mapping's entity.
     - parameter propertyName:   Name of the property to look up in the representation

     - returns: NSObject of the value
     */
    open func valueFromRepresentation(_ representation: CDIRepresentation, forPropertyNamed propertyName: String) -> Any? {
        if let property = entityDescription.propertiesByName[propertyName] {
            return valueFromRepresentation(representation, forProperty: property)
        }
        else {
            return nil
        }
    }

    /**
     Gets the primary key value from the managed object.

     - parameter object: Managed object to get the primary key from

     - returns: Primary key
     */
    open func primaryKeyValueForManagedObject(_ object: NSManagedObject) -> NSObject? {
        if let primaryKeyAttributeName = primaryKeyAttributeName {
            return object.value(forKey: primaryKeyAttributeName) as? NSObject
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
    open func extractRootFromExternalRepresentation(_ externalRepresentation: CDIExternalRepresentation) -> CDIRootRepresentation {
        return externalRepresentation;
    }

    /**
     To keep methods consistant when working with CDIRepresentation or CDIRepresentationArray it is often
     easier to work with just CDIRepresentationArray.

     This method will return a CDIRepresentationArray regardless of the input.

     This will call `extractRootFromExternalRepresentation` to get the base representation.

     - parameter externalRepresentation: External representation to convert

     - returns: CDIRepresentationArray
     */
    open func represenationArrayFromExternalRepresentation(_ externalRepresentation: CDIExternalRepresentation) -> CDIRepresentationArray {

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
    open var relationshipsByName: [String : NSRelationshipDescription] {
        get {
            return entityDescription.relationshipsByName
        }
    }

    // MARK: Private Methods

    /**
     Handles key paths for representations. Will return the value found in the representation for the attribute's lookup key.

     - parameter representation: Representation to find value in
     - parameter attribute:      Attribute description to look for mappedKeyName

     - returns: Value found at the key path
     */
    func valueFromRepresentation(_ representation: CDIRepresentation, forProperty property: NSPropertyDescription) -> Any? {
        var newRepresentation = representation
        var keys = lookupKeyForProperty(property).components(separatedBy: ".")
        var key = keys.removeFirst()

        // Dig into each nested dictionary until there are no more
        while !keys.isEmpty, let newRep = newRepresentation[key] as? CDIRepresentation {
            key = keys.removeFirst()
            newRepresentation = newRep
        }

        return keys.isEmpty ? newRepresentation[key] : nil
    }

    /**
     Function used to look up which key in a representation cooresponds with the property. It will
     use `mappedKeyName` if provided, otherwise it will use the attribute's name.

     - parameter attribute: NSAttributeDescription of the attribute

     - returns: String to look up the attribute in the representation

     - Note: This isn't an extension on NSPropertyDescription because, at least right now, we don't
     want to leak API to other classes.
     */
    func lookupKeyForProperty(_ property: NSPropertyDescription) -> String {
        if let userInfo = property.userInfo, let mappedKeyName = userInfo["mappedKeyName"] as? String {
            return mappedKeyName
        }

        return property.name
    }

    /**
     Returns date for a given representation and attribute. Looks up `dateFormat` in the `userInfo` or
     uses `yyyy-MM-dd'T'HH:mm:ssz` as a default formatter.

     - parameter representationValue: Representation to extract the date string value from
     - parameter attribute:           The attribute description to look for a `dateFormat` on

     - returns: Returns a date optional
     */
    func dateFromRepresentationValue(_ representationValue: NSObject, forAttribute attribute:NSAttributeDescription) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = (attribute.userInfo?["dateFormat"] as? String) ?? "yyyy-MM-dd'T'HH:mm:ssz"

        if let dateString = representationValue as? String {
            return dateFormatter.date(from: dateString)
        }
        else {
            return nil
        }
    }
}
