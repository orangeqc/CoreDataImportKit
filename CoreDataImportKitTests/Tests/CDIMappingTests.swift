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

    // MARK: hasPrimaryKey

    func testHasPrimaryKeyWhenKeyExists() {
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        XCTAssertTrue(mapping.hasPrimaryKey)
    }

    func testHasPrimaryKeyWhenKeyDoesNotExists() {
        let mapping = CDIMapping(entityName: "Printer", inManagedObjectContext: managedObjectContext)
        XCTAssertFalse(mapping.hasPrimaryKey)
    }

    // MARK: createManagedObjectWithRepresentation()

    func testCreateManagedObjectWithRepresentation() {
        let representation = [ "id": 123, "name": "John Doe", "age": 35 ]

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

    // MARK: primaryKeyValueFromRepresentation()

    func testPrimaryKeyValueFromRepresentation() {
        let representation = [ "id": 123, "fullName": "John Doe", "age": 35 ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let primaryKey = mapping.primaryKeyValueFromRepresentation(representation)

        if let pk = primaryKey as? Int {
            XCTAssertEqual(pk, 123)
        }
        else {
            XCTFail("Unable to find primary key")
        }
    }

    // MARK: extractRootFromExternalRepresentation()

    func testExtractRootFromExternalRepresentation() {
        let externalRepresentation : [ [String : NSObject] ] = [
            [ "id": 123, "fullName": "John Doe", "age": 35 ],
            [ "id": 124, "fullName": "Jane Doe", "age": 32 ],
            [ "id": 125, "fullName": "Timmy Doe", "age": 15 ]
        ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let representation = mapping.extractRootFromExternalRepresentation(externalRepresentation)
        XCTAssertEqual(representation as! [NSDictionary], externalRepresentation);
    }

//    `relationshipsForEntity()` - Not 100% positive about this one yet. Will need to see implimentation of cache/import first. Should allow it to loop over the relationships, but don't know what data it will need yet.
//    `mappingForRelationship()` - Again, not positive about this yet. But might need for a mapping to create a mapping for a different entity based on the relationship.

}
