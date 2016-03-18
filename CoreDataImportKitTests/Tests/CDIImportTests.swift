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
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: importRepresentation()

    func testImportRepresentation() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let person: Person = Person.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext),
            company: Company = Company.findFirstByAttribute("id", withValue: 5, inContext: managedObjectContext) {
                XCTAssertEqual(company.id, 5)
                XCTAssertEqual(person.job, company)
        }
        else {
            XCTFail()
        }
    }

    // MARK: importAttributes()

    func testImportAttributes() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)
        cdiImport.importAttributes()

        if let person: Person = Person.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(person.id, 1)
            XCTAssertEqual(person.name, "John Smith")
            XCTAssertEqual(person.age, 30)
        }
        else {
            XCTFail()
        }
    }

    // MARK: buildRelationships()

    func testBuildRelationships() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let person: Person = Person.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext),
        company: Company = Company.findFirstByAttribute("id", withValue: 5, inContext: managedObjectContext) {
                XCTAssertEqual(company.id, 5)
                XCTAssertEqual(person.job, company)
        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationshipsWithAlreadyExitingObject() {
        let c = NSEntityDescription.insertNewObjectForEntityForName("Company", inManagedObjectContext: managedObjectContext) as! Company
        c.id = 5

        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ]
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let person: Person = Person.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext),
            company: Company = Company.findFirstByAttribute("id", withValue: 5, inContext: managedObjectContext) {

                XCTAssertEqual(company.id, 5)
                XCTAssertEqual(person.job, company)
                XCTAssertEqual(c, company)

                let count = Company.countInContext(managedObjectContext)
                XCTAssertEqual(count, 1)

        }
        else {
            XCTFail()
        }
    }

    // MARK: Test callbacks

    func testCallbackShouldImportWithTrue() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes", "shouldImport" : true ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
                XCTAssertEqual(callback.id, 1)
                XCTAssertEqual(callback.testAttribute, "yes")
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldImportWithFalse() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "nope", "shouldImport" : false ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.id, 1)
            XCTAssertNil(callback.testAttribute)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackWillImport() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes" ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.calledWillImport, true)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackDidImport() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes" ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.calledDidImport, true)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldBuildRelationshipWithTrue() {
        let externalRepresentation = [ "id": 1, "shouldBuildRelationship" : true, "everyAttribute": [ "integerAttribute": 3 ] ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext),
            everyAttribute = callback.everyAttribute {
            XCTAssertEqual(callback.calledShouldBuildRelationship, true)
            XCTAssertEqual(everyAttribute.integerAttribute, 3)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldBuildRelationshipWithFalse() {
        let externalRepresentation = [ "id": 1, "shouldBuildRelationship" : false, "everyAttribute": [ "integerAttribute": 3 ] ]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirstByAttribute("id", withValue: 1, inContext: managedObjectContext) {
                XCTAssertEqual(callback.calledShouldBuildRelationship, true)
                XCTAssertNil(callback.everyAttribute)
        }
        else {
            XCTFail()
        }
    }
}
