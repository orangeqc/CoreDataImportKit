//
//  CoreDataImportKitTests.swift
//  CoreDataImportKitTests
//
//  Created by Ryan Mathews on 2/9/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//
// https://developer.apple.com/library/prerelease/mac/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1

import XCTest
import Foundation
import CoreData

@testable import CoreDataImportKit

class CoreDataImportKitTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!

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
        managedObjectContext.persistentStoreCoordinator = psc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            do {
                try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

}
