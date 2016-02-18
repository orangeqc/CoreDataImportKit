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


    // MARK: buildCacheForBaseEntity

    func testBuildCacheForBaseEntity() {
        let representation = [
            [ "id": 123, "name": "John Doe", "age": 35 ],
            [ "id": 124, "name": "John Doe", "age": 35 ]
        ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)

        let cache = CDIManagedObjectCache(externalRepresentation: representation, mapping: mapping)

        cache.buildCacheForBaseEntity()

        if let personPrimaryKeys = cache.primaryKeysCache["Person"] as? [Int] {
            XCTAssertTrue(personPrimaryKeys.contains(123))
            XCTAssertTrue(personPrimaryKeys.contains(124))
        }
        else {
            XCTFail()
        }

        if let personPrimaryKey = cache.primaryKeyCache["Person"] {
            XCTAssertEqual(personPrimaryKey, "id")
        }
        else {
            XCTFail()
        }

        // TODO: Make sure actual objects are looked up
    }
}
