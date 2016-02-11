//
//  CDIMappingTests.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/10/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import XCTest
import Foundation
import CoreData

class CDIMappingTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext?


    override func setUp() {
        super.setUp()

        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle(forClass: self.dynamicType).URLForResource("CDICoreData", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = psc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            do {
                try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let userInfo = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedObjectContext!)?.userInfo as! [String : AnyObject]
        XCTAssertTrue(userInfo["relatedByAttribute"] as! String == "id")
    }

}
