//
//  Error.swift
//  Valley
//
//  Created by Jahid Hassan on 11/16/18.
//  Copyright © 2018 Jahid Hassan. All rights reserved.
//

import Foundation

/// Valley error types, of `Error` type
/// - invalidURL(String)
/// - imageNotFound(String)
public enum ValleyError: Error {
    case invalidURL(String)
    case imageNotFound(String)
}
