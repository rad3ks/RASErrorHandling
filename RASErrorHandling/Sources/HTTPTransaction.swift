//
// HTTPTransaction.swift
//
// Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

/// Couples request and response
internal struct HTTPTransaction {
    
    /// Request and its json
    internal let request: URLRequest
    
    /// Response and its json
    internal let response: HTTPResponse
    
}

