//
//  NSManagedObjectExtensionsTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 3/30/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import XCTest
import CoreDataImportKit

class NSManagedObjectExtensionsTests: CoreDataImportKitTests {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testImportRepresentation() {
        let externalRepresentation: CDIExternalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        
        Person.cdiImportFromRepresentation(externalRepresentation: externalRepresentation, inContext: managedObjectContext)
        
        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {
            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(person.job, company)
        }
        else {
            XCTFail()
        }
    }

}
