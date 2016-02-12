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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let userInfo = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedObjectContext)?.userInfo as! [String : AnyObject]
        XCTAssertTrue(userInfo["relatedByAttribute"] as! String == "id")
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

    // MARK: createManagedObjectWithRepresentation

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

    // MARK: updateManagedObjectAttributes:withRepresentation:

    func testUpdateManagedObjectAttributesWithRepresentation() {
        
    }

//    `updateEntityAttributes(entity withRepresentation:rep)` - Updates an existing entity with the attributes in the representation. Makes sure values are new before setting them.
//    `extractRootFromExternalRepresentation(rep)` - Returns dictionary or array based on the representation.
//    `primaryKeyValueForRepresentation(rep)` - Returns the value of the primary key
//    `relationshipsForEntity()` - Not 100% positive about this one yet. Will need to see implimentation of cache/import first. Should allow it to loop over the relationships, but don't know what data it will need yet.
//    `mappingForRelationship()` - Again, not positive about this yet. But might need for a mapping to create a mapping for a different entity based on the relationship.

}
