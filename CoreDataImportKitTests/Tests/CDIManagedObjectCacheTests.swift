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


    // MARK: buildCacheForBaseEntity()

//    func testBuildCacheForBaseEntity() {
//        let representation = [ [ "id": 123 ], [ "id": 124 ] ]
//
//        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
//        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])
//
//        let cache = CDIManagedObjectCache(context: managedObjectContext)
//
//        cache.buildCacheForBaseEntity()
//
//        guard let   personPrimaryKeys   = cache.primaryKeyValuesCache["Person"] as? Set<Int>,
//                    personPrimaryKey    = cache.primaryKeyAttributeNameCache["Person"],
//                    cachedObject        = cache.objectCache["Person"]?[123] else {
//                XCTFail()
//                return
//        }
//
//        XCTAssertTrue(personPrimaryKeys.contains(123))
//        XCTAssertTrue(personPrimaryKeys.contains(124))
//
//        XCTAssertEqual(personPrimaryKey, "id")
//
//        XCTAssertEqual(cachedObject, managedObject)
//    }
//
//    // TODO: Write test where there is no object
//
//    // MARK: buildCacheForRelatedEntities()
//
//    func testBuildCacheForRelatedEntities() {
//        let representation = [
//            [ "id": 123, "companyId": 5 ],
//            [ "id": 124, "companyId": 5 ]
//        ]
//
//        let companyMapping = CDIMapping(entityName: "Company", inManagedObjectContext: managedObjectContext)
//        let companyObject = companyMapping.createManagedObjectWithRepresentation([ "id": 5 ])
//
//        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
//        let cache = CDIManagedObjectCache(context: managedObjectContext)
//
//        cache.buildCacheForRelatedEntities()
//
//        guard let   companyPrimaryKeys   = cache.primaryKeyValuesCache["Company"] as? Set<Int>,
//            companyPrimaryKey    = cache.primaryKeyAttributeNameCache["Company"],
//            cachedCompanyObject  = cache.objectCache["Company"]?[5] else {
//                XCTFail()
//                return
//        }
//
//        XCTAssertTrue(companyPrimaryKeys.contains(5))
//
//        XCTAssertEqual(companyPrimaryKey, "id")
//
//        XCTAssertEqual(cachedCompanyObject, companyObject)
//    }
//
//    // TODO: Make sure there are correct error messages / asserts for wrong userInfo key names
//
//    // MARK: managedObjectExistsForRepresentation()
//
//    func testManagedObjectExistsForRepresentationThatExists() {
//        let representation = [ [ "id": 123 ], [ "id": 124 ] ]
//
//        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
//        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])
//
//        let cache = CDIManagedObjectCache(context: managedObjectContext)
//
//        cache.buildCacheForBaseEntity()
//
//        guard let cachedObject = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: 123) else {
//                XCTFail()
//                return
//        }
//
//        XCTAssertEqual(cachedObject, managedObject)
//    }
//
//    func testManagedObjectExistsForRepresentationThatDoesNotExist() {
//        let representation = [ [ "id": 123 ], [ "id": 124 ] ]
//
//        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
//
//        let cache = CDIManagedObjectCache(context: managedObjectContext)
//
//        cache.buildCacheForBaseEntity()
//
//        if cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: 124) != nil {
//            XCTFail()
//        }
//    }
//
//    // MARK: addManagedObject()
//
//    func testAddManagedObject() {
//        let representation = [ [ "id": 123 ], [ "id": 124 ] ]
//
//        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
//
//        let cache = CDIManagedObjectCache(externalRepresentation: representation, mapping: mapping, context: managedObjectContext)
//
//        cache.buildCacheForBaseEntity()
//
//        if let _ = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: 123) {
//            XCTFail()
//        }
//
//        let managedObject = mapping.createManagedObjectWithRepresentation(representation[0])
//        cache.addManagedObjectToCache(managedObject)
//
//        if let cachedObject = cache.managedObjectForEntity(mapping.entityName, primaryKeyValue: 123) {
//            XCTAssertEqual(managedObject, cachedObject)
//        }
//        else {
//            XCTFail()
//        }
//    }
}
