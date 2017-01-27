//
//  CDIManagedObjectCacheTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/16/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataImportKit

class CDIManagedObjectCacheTests: CoreDataImportKitTests {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }


    // MARK: buildCacheForExternalRepresentation()

    func testBuildCacheForExternalRepresentation() {
        let representation = [
            [ "id": 123, "companyId": 5 ],
            [ "id": 124, "companyId": 5 ]
        ] as CDIExternalRepresentation

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cache = CDIManagedObjectCache(context: managedObjectContext)
        cache.buildCacheForExternalRepresentation(representation, usingMapping: mapping)

        guard let companyPrimaryKeys = cache.primaryKeyValuesCache["Company"] as? Set<Int>,
            let personPrimaryKeys   = cache.primaryKeyValuesCache["Person"] as? Set<Int> else {
                XCTFail()
                return
        }

        XCTAssertTrue(personPrimaryKeys.contains(123))
        XCTAssertTrue(personPrimaryKeys.contains(124))
        XCTAssertTrue(companyPrimaryKeys.contains(5))
    }

    // MARK: managedObjectForRepresentation(_:usingMapping:)

    func testManagedObjectExistsForRepresentationThatExists() {
        let representation: CDIRepresentationArray = [ [ "id": 123 as NSObject ], [ "id": 124 ] ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])

        let cache = CDIManagedObjectCache(context: managedObjectContext)

        cache.buildCacheForExternalRepresentation(representation, usingMapping: mapping)

        guard let cachedObject = cache.managedObjectForRepresentation(representation[0], usingMapping: mapping) else {
                XCTFail()
                return
        }

        XCTAssertEqual(cachedObject, managedObject)
    }

    func testManagedObjectExistsForRepresentationThatExistsThatDoesNotExist() {
        let representation: CDIRepresentationArray = [ [ "id": 123 as NSObject ], [ "id": 124 ] ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cache = CDIManagedObjectCache(context: managedObjectContext)

        cache.buildCacheForExternalRepresentation(representation, usingMapping: mapping)

        if cache.managedObjectForRepresentation(representation[0], usingMapping: mapping) != nil {
            XCTFail()
        }
    }

    // MARK: managedObjectForPrimaryKey(_:usingMapping:)

    func testmanagedObjectForPrimaryKey() {
        let representation: CDIRepresentationArray = [ [ "id": 123 ], [ "id": 124 ] ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])

        let cache = CDIManagedObjectCache(context: managedObjectContext)

        cache.buildCacheForExternalRepresentation(representation, usingMapping: mapping)

        guard let cachedObject = cache.managedObjectWithPrimaryKey(123 as NSObject, usingMapping: mapping) else {
            XCTFail()
            return
        }

        XCTAssertEqual(cachedObject, managedObject)
    }


    // MARK: addManagedObjectToCache()

    func testAddManagedObject() {
        let representation: CDIRepresentationArray = [ [ "id": 123 ], [ "id": 124 ] ]

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cache = CDIManagedObjectCache(context: managedObjectContext)

        cache.buildCacheForExternalRepresentation(representation, usingMapping: mapping)

        if let _ = cache.managedObjectWithPrimaryKey(123 as NSObject, usingMapping: mapping) {
            XCTFail()
        }

        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])
        cache.addManagedObjectToCache(managedObject, usingMapping: mapping)

        if let cachedObject = cache.managedObjectWithPrimaryKey(123 as NSObject, usingMapping: mapping) {
            XCTAssertEqual(managedObject, cachedObject)
        }
        else {
            XCTFail()
        }
    }
}
