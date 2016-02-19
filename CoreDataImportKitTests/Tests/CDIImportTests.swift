//
//  CDIImportTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/19/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataImportKit

class CDIImportTests: CoreDataImportKitTests {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: importAttributes()

    func testImportAttributes() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)
        cdiImport.importAttributes()

        // Look up user
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "id = \(1)")
        fetchRequest.predicate = predicate
        do {
            if let person = try managedObjectContext.executeFetchRequest(fetchRequest).first as? Person {
                XCTAssertEqual(person.id, 1)
                XCTAssertEqual(person.name, "John Smith")
                XCTAssertEqual(person.age, 30)
            }
            else {
                XCTFail()
            }
        }
        catch {
            XCTFail()
        }
    }

    // MARK: buildRelationships()

    func testBuildRelationships() {

    }

}
