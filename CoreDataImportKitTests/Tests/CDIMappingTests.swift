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

extension CDIMapping: Equatable {}

public func ==(lhs: CDIMapping, rhs: CDIMapping) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

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
            let computerMapping = mapping.mappingForRelationship(computer){

            XCTAssertEqual(computerMapping.entityName, "Computer")
            XCTAssertEqual(computerMapping.context, managedObjectContext)
        }
        else {
            XCTFail()
        }
    }

    func testMappingForRelationshipPointsBackToItself() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        if let boss = mapping.entityDescription.relationshipsByName["boss"],
            let personMapping = mapping.mappingForRelationship(boss){

            XCTAssertEqual(personMapping, mapping)
        }
        else {
            XCTFail()
        }
    }

    // MARK: createManagedObjectWithRepresentation(_:)

    func testCreateManagedObjectWithRepresentation() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ] as [String : Any]

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
        let managedObject = mapping.createManagedObjectWithRepresentation(representation as CDIRepresentation)

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
        let managedObject = mapping.createManagedObjectWithPrimaryKey(123 as NSObject)

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
        let representation: CDIRepresentation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

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
    
    func testUpdateManagedObjectAttributesWithRepresentationWithArrayForString() {
        let representation: CDIRepresentation = [ "id": 123, "fullName": ["John", "Doe"] ]
        
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)
        mapping.updateManagedObjectAttributes(managedObject, withRepresentation:representation)
        
        XCTAssertEqual(managedObject.entity.name!, "Person")
        
        if let person = managedObject as? Person {
            XCTAssertEqual(person.id, 123)
            XCTAssertEqual(person.name, "(\n    John,\n    Doe\n)")
        }
        else {
            XCTFail("Unable to create person")
        }
    }

    func testUpdateManagedObjectAttributesWithRepresentationForAllAttributeTypes() {
        let representation: CDIRepresentation = [
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

        let dateFormat1 = DateFormatter()
        dateFormat1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let dateFormat2 = DateFormatter()
        dateFormat2.locale = Locale.current
        dateFormat2.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat2.dateFormat = "MM/DD/YY"

        if let eat = managedObject as? EveryAttributeType {
            XCTAssertEqual(eat.booleanAttribute!, true)
            XCTAssertEqual(eat.dateAttribute!, dateFormat1.date(from: "2016-02-25T11:01:51-08:00"))
            XCTAssertEqual(eat.dateAttributeCustomized!, dateFormat2.date(from: "02/25/2016"))
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
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ] as [String : Any]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let primaryKey = mapping.primaryKeyValueFromRepresentation(representation)

        XCTAssertEqual(primaryKey as? Int, 123)
    }

    // MARK: valueFromRepresentation(_:forPropertyNamed:)

    // This also tests valueFromRepresentation(_:forProperty:)

    func testValueFromRepresentationForPropertyNamed() {
        let representation: CDIRepresentation = [ "id": 123, "fullName": "John Doe", "companyId": 5 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "name")

        XCTAssertEqual(value as? String, "John Doe")
    }

    func testValueFromRepresentationForPropertyNamedForRelationship() {
        let representation: CDIRepresentation = [ "id": 123, "fullName": "John Doe", "companyId": 5 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "job")

        XCTAssertEqual(value as? Int, 5)
    }

    func testValueFromRepresentationForPropertyNamedWithNestedValue() {
        let computer = [ "name": "John Smith's MacBook", "purchased": "2016-02-25T11:01:51-08:00", "cost": 1100.99 ] as CDIExternalRepresentation
        let representation: CDIRepresentation = [ "id": 123 as NSObject, "fullName": "John Doe" as NSObject, "computer": computer as! NSObject ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let value = mapping.valueFromRepresentation(representation, forPropertyNamed: "computer")

        XCTAssertEqual((value as? [String : NSObject])!, computer as! [String : NSObject])
    }

    // MARK: primaryKeyValueForManagedObject(_:)

    func testPrimaryKeyValueForManagedObject() {
        let representation: CDIRepresentation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation)

        if let primaryKey = mapping.primaryKeyValueForManagedObject(managedObject) as? Int {
            XCTAssertEqual(primaryKey, 123)
        }
        else { XCTFail() }
    }

    // MARK: extractRootFromExternalRepresentation(_:)

    func testExtractRootFromExternalRepresentation() {
        let externalRepresentation : NSObject = [
            [ "id": 123, "fullName": "John Doe", "age": 35],
            [ "id": 124, "fullName": "Jane Doe", "age": 32],
            [ "id": 125, "fullName": "Timmy Doe", "age": 15]
        ] as NSObject

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let representation = mapping.extractRootFromExternalRepresentation(externalRepresentation as CDIExternalRepresentation)
        if let representation = representation as? NSObject {
            XCTAssertEqual(representation, externalRepresentation)
        }
        else { XCTFail() }
    }

    // MARK: represenationArrayFromExternalRepresentation(_:)

    func testRepresenationArrayFromExternalRepresentationWithRepresentationArray() {
        let externalRepresentation : NSObject = [
            [ "id": 123, "fullName": "John Doe", "age": 35 ],
            [ "id": 124, "fullName": "Jane Doe", "age": 32 ],
            [ "id": 125, "fullName": "Timmy Doe", "age": 15 ]
        ] as NSObject

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)

        let representation = mapping.represenationArrayFromExternalRepresentation(externalRepresentation as CDIExternalRepresentation) as NSObject
        XCTAssertEqual(representation, externalRepresentation)
    }

    func testRepresenationArrayFromExternalRepresentationWithSingleRepresentation() {
        let externalRepresentation = [ "id": 123 as NSObject, "fullName": "John Doe", "age": 35 ] as NSObject

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)

        let rep = mapping.represenationArrayFromExternalRepresentation(externalRepresentation as CDIExternalRepresentation) as NSObject
        XCTAssertEqual(rep, [externalRepresentation] as NSObject)
    }

    // MARK: relationshipsByName

    func testRelationshipsByName() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext)

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

    // MARK: Test callbacks

    func testCallbackShouldImportAttributeWithTrue() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes", "shouldImportAttribute" : true ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1 as NSObject, inContext: managedObjectContext) {
            XCTAssertEqual(callback.id, 1)
            XCTAssertEqual(callback.calledShouldImportAttribute, true)
            XCTAssertEqual(callback.testAttribute, "yes")
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldImportAttributeWithFalse() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes", "shouldImportAttribute" : false ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1 as NSObject, inContext: managedObjectContext) {
            XCTAssertEqual(callback.id, 1)
            XCTAssertEqual(callback.calledShouldImportAttribute, true)
            XCTAssertNil(callback.testAttribute)
        }
        else {
            XCTFail()
        }
    }
}
