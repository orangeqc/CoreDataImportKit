//
//  CDIMappingTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/10/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataImportKit

class CDIMappingTests: CoreDataImportKitTests {

    override func setUp() {
        super.setUp()       
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: entityName

    func testEntityName() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        XCTAssertEqual(mapping.entityName, "Person")
    }

    // MARK: mappingForRelationship(_:)

    func testMappingForRelationship() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        if let computer = mapping.entityDescription.relationshipsByName["computer"],
            computerMapping = mapping.mappingForRelationship(computer){

            XCTAssertEqual(computerMapping.entityName, "Computer")
            XCTAssertEqual(computerMapping.context, managedObjectContext)
        }
        else {
            XCTFail()
        }
    }

    // MARK: createManagedObjectWithRepresentation(_:)

    func testCreateManagedObjectWithRepresentation() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)

        XCTAssertEqual(managedObject.entity.name!, "Person")

        if let person = managedObject as? Person {
            XCTAssertEqual(person.id, 123)
            XCTAssertNil(person.name)
        }
        else {
            XCTFail("Unable to create person")
        }
    }

    func testCreateManagedObjectWithRepresentationForEntityWithNoPrimaryKey() {
        let representation = [ "name": "Big Store Printer" ]

        let mapping = CDIMapping(entityName: "Printer", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)

        XCTAssertEqual(managedObject.entity.name!, "Printer")

        if let printer = managedObject as? Printer {
            XCTAssertNil(printer.name)
        }
        else {
            XCTFail("Unable to create printer")
        }
    }

    // MARK: createManagedObjectWithPrimaryKey(_:)

    func testCreateManagedObjectWithPrimaryKey() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithPrimaryKey(123)

        XCTAssertEqual(managedObject.entity.name!, "Person")

        if let person = managedObject as? Person {
            XCTAssertEqual(person.id, 123)
            XCTAssertNil(person.name)
        }
        else {
            XCTFail("Unable to create person")
        }
    }

    // MARK: updateManagedObjectAttributes(_:withRepresentation:)

    func testUpdateManagedObjectAttributesWithRepresentation() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)
        mapping.updateManagedObjectAttributes(managedObject, withRepresentation:representation)

        XCTAssertEqual(managedObject.entity.name!, "Person")

        if let person = managedObject as? Person {
            XCTAssertEqual(person.id, 123)
            XCTAssertEqual(person.name, "John Doe")
            XCTAssertEqual(person.age, 35)
        }
        else {
            XCTFail("Unable to create person")
        }
    }

    func testUpdateManagedObjectAttributesWithRepresentationForAllAttributeTypes() {
        let representation = [
            "booleanAttribute": true,
            "dateAttribute": "2016-02-25T11:01:51-08:00",
            "dateAttributeCustomized": "02/25/2016",
            "decimalAttribute": 11.2,
            "doubleAttribute": 12.3,
            "floatAttribute": 13.4,
            "integerAttribute": 14,
            "keyPath": [ "attributeName": "keyPathValue" ],
            "stringAttribute": "Hello world"
        ]

        let mapping = CDIMapping(entityName: "EveryAttributeType", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)
        mapping.updateManagedObjectAttributes(managedObject, withRepresentation:representation)

        XCTAssertEqual(managedObject.entity.name!, "EveryAttributeType")

        let dateFormat1 = NSDateFormatter()
        dateFormat1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let dateFormat2 = NSDateFormatter()
        dateFormat2.locale = NSLocale.currentLocale()
        dateFormat2.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormat2.dateFormat = "MM/DD/YY"

        if let eat = managedObject as? EveryAttributeType {
            XCTAssertEqual(eat.booleanAttribute!, true)
            XCTAssertEqual(eat.dateAttribute!, dateFormat1.dateFromString("2016-02-25T11:01:51-08:00"))
            XCTAssertEqual(eat.dateAttributeCustomized!, dateFormat2.dateFromString("02/25/2016"))
            XCTAssertEqual(eat.decimalAttribute!, 11.2)
            XCTAssertEqual(eat.doubleAttribute!, 12.3)
            XCTAssertEqualWithAccuracy(eat.floatAttribute!.floatValue, Float(13.4), accuracy: 0.01)
            XCTAssertEqual(eat.integerAttribute!, 14)
            XCTAssertEqual(eat.stringAttribute, "Hello world")
            XCTAssertEqual(eat.keyPathAttribute, "keyPathValue")
        }
        else {
            XCTFail("Unable to create entity")
        }
    }

    // MARK: primaryKeyValueFromRepresentation(_:)

    func testPrimaryKeyValueFromRepresentation() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let primaryKey = mapping.primaryKeyValueFromRepresentation(representation)

        XCTAssertEqual(primaryKey as? Int, 123)
    }

    // MARK: valueFromRepresentation(_:forPropertyNamed:)

    // This also tests valueFromRepresentation(_:forProperty:)

    func testValueFromRepresentationForPropertyNamed() {
        let representation = [ "id": 123, "fullName": "John Doe", "companyId": 5 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "name")

        XCTAssertEqual(value as? String, "John Doe")
    }

    func testValueFromRepresentationForPropertyNamedForRelationship() {
        let representation = [ "id": 123, "fullName": "John Doe", "companyId": 5 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "job")

        XCTAssertEqual(value as? Int, 5)
    }

    func testValueFromRepresentationForPropertyNamedWithNestedValue() {
        let computer = [ "name": "John Smith's MacBook", "purchased": "2016-02-25T11:01:51-08:00", "cost": 1100.99 ]
        let representation: CDIRepresentation = [ "id": 123, "fullName": "John Doe", "computer": computer ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "computer")

        XCTAssertEqual((value as? CDIRepresentation)!, computer)
    }

    // MARK: primaryKeyValueForManagedObject(_:)

    func testPrimaryKeyValueForManagedObject() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)

        let primaryKey = mapping.primaryKeyValueForManagedObject(managedObject)

        XCTAssertEqual(primaryKey, 123)
    }

    // MARK: extractRootFromExternalRepresentation(_:)

    func testExtractRootFromExternalRepresentation() {
        let externalRepresentation : CDIRepresentationArray = [
            [ "id": 123, "fullName": "John Doe", "age": 35 ],
            [ "id": 124, "fullName": "Jane Doe", "age": 32 ],
            [ "id": 125, "fullName": "Timmy Doe", "age": 15 ]
        ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let representation = mapping.extractRootFromExternalRepresentation(externalRepresentation)
        XCTAssertEqual(representation as! [NSDictionary], externalRepresentation);
    }

    // MARK: represenationArrayFromExternalRepresentation(_:)

    func testRepresenationArrayFromExternalRepresentationWithRepresentationArray() {
        let externalRepresentation : CDIRepresentationArray = [
            [ "id": 123, "fullName": "John Doe", "age": 35 ],
            [ "id": 124, "fullName": "Jane Doe", "age": 32 ],
            [ "id": 125, "fullName": "Timmy Doe", "age": 15 ]
        ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)

        XCTAssertEqual(mapping.represenationArrayFromExternalRepresentation(externalRepresentation), externalRepresentation)
    }

    func testRepresenationArrayFromExternalRepresentationWithSingleRepresentation() {
        let externalRepresentation : CDIRepresentation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)

        XCTAssertEqual(mapping.represenationArrayFromExternalRepresentation(externalRepresentation), [externalRepresentation])
    }

    // MARK: relationshipsByName

    func testRelationshipsByName() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let personEntity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedObjectContext)

        XCTAssertEqual(mapping.relationshipsByName, (personEntity?.relationshipsByName)!)
    }

    // MARK: lookupKeyForProperty(_:)

    // This is a private function, but we want to test that it properly looks up attributes based on what is in the userInfo
    func testLookupKeyForProperty() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let nameProperty = mapping.entityDescription.propertiesByName["name"]
        let idProperty = mapping.entityDescription.propertiesByName["id"]
        let ageProperty = mapping.entityDescription.propertiesByName["age"]
        XCTAssertEqual(mapping.lookupKeyForProperty(nameProperty!), "fullName")
        XCTAssertEqual(mapping.lookupKeyForProperty(idProperty!), "id")
        XCTAssertEqual(mapping.lookupKeyForProperty(ageProperty!), "age")
    }

}
