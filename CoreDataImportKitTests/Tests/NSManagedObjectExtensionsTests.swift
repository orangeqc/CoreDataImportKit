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
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        
        Person.cdiImportFromRepresentation(externalRepresentation: externalRepresentation as CDIExternalRepresentation, inContext: managedObjectContext)
        
        if let person: Person = Person.findFirstByAttribute("id", withValue: 1 as NSObject, inContext: managedObjectContext),
            let company: Company = Company.findFirstByAttribute("id", withValue: 5 as NSObject, inContext: managedObjectContext) {
            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(person.job, company)
        }
        else {
            XCTFail()
        }
    }

}
