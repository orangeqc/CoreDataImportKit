//
//  CDIImportJsonTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/29/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
//  CDIImportTests.swift focuses on testing the methodsof CDIImport. This class focuses on
//  importing various json formats and providing examples of how to handle that data.

import XCTest
import CoreDataImportKit

class CDIImportJsonTests: CoreDataImportKitTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func representationFromJSONFile(_ fileName: String) -> Any? {
        let url = Bundle(for: CDIImportJsonTests.self).url(forResource: fileName, withExtension: "json")
        let data = try? Data(contentsOf: url!)

        do {
            return try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
        }
        catch {
            print("Had error")
        }
        return nil;
    }

    func checkForJohnSmith() {
        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(person.id, 1)
            XCTAssertEqual(person.name, "John Smith")
            XCTAssertEqual(person.age, 30)
            XCTAssertEqual(person.job?.id, 5)
        }
        else {
            XCTFail()
        }
    }

    func checkForPeopleCount(_ count: Int) {
        let peopleCount = Person.countInContext(managedObjectContext)
        XCTAssertEqual(peopleCount, count)
    }

    func checkForComputerCount(_ count: Int) {
        let computerCount = Computer.countInContext(managedObjectContext)
        XCTAssertEqual(computerCount, count)
    }

    func testPeople() {
        let people = representationFromJSONFile("People")!

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: people, mapping: mapping, context: managedObjectContext)
        cdiImport.importRepresentation()


        checkForJohnSmith()
        checkForPeopleCount(5)
    }

    func testPeopleWithRoot() {
        let people = representationFromJSONFile("PeopleWithRoot")! as! [ String: AnyObject ]

        guard let rep = people["people"] else {
            XCTFail()
            return
        }

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: rep, mapping: mapping, context: managedObjectContext)
        cdiImport.importRepresentation()

        checkForJohnSmith()
        checkForPeopleCount(5)
    }

    func testPerson() {
        let person = representationFromJSONFile("Person")!

        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: person, mapping: mapping, context: managedObjectContext)
        cdiImport.importRepresentation()


        checkForJohnSmith()
        checkForPeopleCount(1)

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext), let computer = person.computer {
            XCTAssertEqual(computer.name, "John Smith's MacBook")
            XCTAssertEqual(computer.cost, 1100.99)

            let dateFormat1 = DateFormatter()
            dateFormat1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"

            XCTAssertEqual(computer.purchased, dateFormat1.date(from: "2016-02-25T11:01:51-08:00"))
        }
        else {
            XCTFail()
        }
    }

    func testCompany() {
        let company = representationFromJSONFile("Company")!

        let mapping = CDIMapping(entityName: "Company", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: company, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        checkForJohnSmith()
        checkForPeopleCount(2)
        checkForComputerCount(2)

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext), let computer = person.computer {
            XCTAssertEqual(computer.name, "John Smith's MacBook")
            XCTAssertEqual(computer.cost, 1100.99)

            let dateFormat1 = DateFormatter()
            dateFormat1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"

            XCTAssertEqual(computer.purchased, dateFormat1.date(from: "2016-02-25T11:01:51-08:00"))
        }
        else {
            XCTFail()
        }
    }
}
