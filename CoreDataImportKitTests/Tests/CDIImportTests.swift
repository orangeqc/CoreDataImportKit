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
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {
                XCTAssertEqual(company.id, 5)
                XCTAssertEqual(person.job, company)
        }
        else {
            XCTFail()
        }
    }

    // MARK: importAttributes()

    func testImportAttributes() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)
        cdiImport.importAttributes()

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(person.id, 1)
            XCTAssertEqual(person.name, "John Smith")
            XCTAssertEqual(person.age, 30)
        }
        else {
            XCTFail()
        }
    }

    // MARK: buildRelationships()

    func testBuildRelationships_ToOne() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
        let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {
            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(person.job, company)
            XCTAssertTrue(company.employees!.contains(person))
        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_ToOneWithMultipleImports() {
        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ], [ "id" : 2, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let person1: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let person2: Person = Person.findFirst(by: "id", withValue: 2, inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {
            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(person1.job, company)
            XCTAssertEqual(person2.job, company)
            XCTAssertEqual(Company.countInContext(managedObjectContext), 1)
            XCTAssertTrue(company.employees!.contains(person1))
            XCTAssertTrue(company.employees!.contains(person2))
        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_ToOneWithAlreadyExitingObject() {
        let c = NSEntityDescription.insertNewObject(forEntityName: "Company", into: managedObjectContext) as! Company
        c.id = 5

        let externalRepresentation = [ [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ] ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Person", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let person: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {

            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(person.job, company)
            XCTAssertEqual(c, company)
            XCTAssertTrue(company.employees!.contains(person))

            let count = Company.countInContext(managedObjectContext)
            XCTAssertEqual(count, 1)

        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_NestedToOneWithMultipleImports() {
        let externalRepresentation: CDIRepresentationArray = [
            [ "name" : "Comp 1", "cost": 300, "company" : [ "id" : 5, "name" : "Build Inc." ] ],
            [ "name" : "Comp 2", "cost": 300, "company" : [ "id" : 5, "name" : "Build Inc." ] ] ]
        let mapping = CDIMapping(entityName: "Computer", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let computer1: Computer = Computer.findFirst(by: "name", withValue: "Comp 1", inContext: managedObjectContext),
            let computer2: Computer = Computer.findFirst(by: "name", withValue: "Comp 2", inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {
            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(company.name, "Build Inc.")
            XCTAssertEqual(computer1.company, company)
            XCTAssertEqual(computer2.company, company)
            XCTAssertEqual(Company.countInContext(managedObjectContext), 1)
            XCTAssertTrue(company.computers!.contains(computer1))
            XCTAssertTrue(company.computers!.contains(computer2))
        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_NestedToOneWithAlreadyExitingObject() {
        let c = NSEntityDescription.insertNewObject(forEntityName: "Company", into: managedObjectContext) as! Company
        c.id = 5

        let externalRepresentation: CDIRepresentationArray = [
            [ "name" : "Comp 1", "cost": 300, "company" : [ "id" : 5, "name" : "Build Inc." ] ] ]
        let mapping = CDIMapping(entityName: "Computer", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let computer: Computer = Computer.findFirst(by: "name", withValue: "Comp 1", inContext: managedObjectContext),
            let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext) {

            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(computer.company, company)
            XCTAssertEqual(c, company)
            XCTAssertTrue(company.computers!.contains(computer))

            XCTAssertEqual(Company.countInContext(managedObjectContext), 1)
        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_NestedToMany() {
        let externalRepresentation: CDIExternalRepresentation = [
            "id": 5, "name" : "Build Inc.", "employees": [
                [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ],
                [ "id" : 2, "fullName" : "Jane Smith", "age": 32, "companyId": 5 ]
            ]
        ] as CDIExternalRepresentation
        let mapping = CDIMapping(entityName: "Company", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext),
            let person1: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let person2: Person = Person.findFirst(by: "id", withValue: 2, inContext: managedObjectContext) {

            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(company.name, "Build Inc.")
            XCTAssertEqual(person1.job, company)
            XCTAssertEqual(person2.job, company)
            XCTAssertEqual(company.employees?.count, 2)
            XCTAssertEqual(Company.countInContext(managedObjectContext), 1)
            XCTAssertEqual(Person.countInContext(managedObjectContext), 2)

        }
        else {
            XCTFail()
        }
    }

    func testBuildRelationships_NestedToManyWithAlreadyExitingObject() {
        let p = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedObjectContext) as! Person
        p.id = 1

        let externalRepresentation: CDIExternalRepresentation = [
            "id": 5, "name" : "Build Inc.", "employees": [
                [ "id" : 1, "fullName" : "John Smith", "age": 30, "companyId": 5 ],
                [ "id" : 2, "fullName" : "Jane Smith", "age": 32, "companyId": 5 ]
            ]
        ]
        let mapping = CDIMapping(entityName: "Company", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importAttributes()
        cdiImport.buildRelationships()

        if let company: Company = Company.findFirst(by: "id", withValue: 5, inContext: managedObjectContext),
            let person1: Person = Person.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let person2: Person = Person.findFirst(by: "id", withValue: 2, inContext: managedObjectContext) {

            XCTAssertEqual(company.id, 5)
            XCTAssertEqual(company.name, "Build Inc.")
            XCTAssertEqual(person1.job, company)
            XCTAssertEqual(person1.name, "John Smith")
            XCTAssertEqual(person1, p)
            XCTAssertEqual(person2.job, company)
            XCTAssertEqual(company.employees?.count, 2)
            XCTAssertEqual(Company.countInContext(managedObjectContext), 1)
            XCTAssertEqual(Person.countInContext(managedObjectContext), 2)

        }
        else {
            XCTFail()
        }
    }

    // MARK: Test callbacks

    func testCallbackShouldImport_WithTrue() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes", "shouldImport" : true ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
                XCTAssertEqual(callback.id, 1)
                XCTAssertEqual(callback.testAttribute, "yes")
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldImport_WithFalse() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "nope", "shouldImport" : false ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.id, 1)
            XCTAssertNil(callback.testAttribute)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackWillImport() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes" ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.calledWillImport, true)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackDidImport() {
        let externalRepresentation = [ "id": 1, "testAttribute" : "yes" ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
            XCTAssertEqual(callback.calledDidImport, true)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldBuildRelationship_WithTrue() {
        let externalRepresentation = [ "id": 1, "shouldBuildRelationship" : true, "everyAttribute": [ "integerAttribute": 3 ] ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext),
            let everyAttribute = callback.everyAttribute {
            XCTAssertEqual(callback.calledShouldBuildRelationship, true)
            XCTAssertEqual(everyAttribute.integerAttribute, 3)
        }
        else {
            XCTFail()
        }
    }

    func testCallbackShouldBuildRelationship_WithFalse() {
        let externalRepresentation = [ "id": 1, "shouldBuildRelationship" : false, "everyAttribute": [ "integerAttribute": 3 ] ] as [String : Any]
        let mapping = CDIMapping(entityName: "Callback", inManagedObjectContext: managedObjectContext)
        let cdiImport = CDIImport(externalRepresentation: externalRepresentation, mapping: mapping, context: managedObjectContext)

        cdiImport.importRepresentation()

        if let callback: Callback = Callback.findFirst(by: "id", withValue: 1, inContext: managedObjectContext) {
                XCTAssertEqual(callback.calledShouldBuildRelationship, true)
                XCTAssertNil(callback.everyAttribute)
        }
        else {
            XCTFail()
        }
    }
}
