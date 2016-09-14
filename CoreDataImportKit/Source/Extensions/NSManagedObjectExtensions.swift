//
//  NSManagedObjectExtensions.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 3/30/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // Assumption: If you use mogenerator, this class method will be
    // overwritten with the entity name
    public class func entityName() -> NSString {
        return NSString(string: NSStringFromClass(self).components(separatedBy: ".").last!)
    }
    
    public class func cdiImportFromRepresentation(externalRepresentation representation: CDIExternalRepresentation, inContext context: NSManagedObjectContext) {
        
        let mapping = CDIMapping(entityName: self.entityName() as String, inManagedObjectContext: context)
        let cdiImport = CDIImport(externalRepresentation: representation, mapping: mapping, context: context)
        cdiImport.importRepresentation()
        
    }
    
}
