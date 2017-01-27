//
//  CDIRepresentation.swift
//  CoreDataImportKit
//
//  Created by Ryan Mathews on 2/16/16.
//  Copyright © 2016 OrangeQC. All rights reserved.
//

import Foundation

/// External representation of the data. This will be a direct representation of the external data, normally from an API.
public typealias CDIExternalRepresentation = Any

/// This will be either a CDIRepresentation or CDIRepresentationArray
public typealias CDIRootRepresentation = Any

/// CDIRepresentation is a dictionary representing the data to be imported to a single managed object
public typealias CDIRepresentation = [ String : Any ]

/// CDIRepresentationArray is an array of CDIRepresentation
public typealias CDIRepresentationArray = [ CDIRepresentation ]
