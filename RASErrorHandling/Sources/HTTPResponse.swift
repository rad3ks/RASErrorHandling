//
// HTTPResponse.swift
//
// Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

/// Represents `HTTPURLResponse` and response body (as json) coupled together
internal struct HTTPResponse {
    
    /// Native `HTTPURLResponse`
    internal let response: HTTPURLResponse
    
    /// Associated response body expressed as optional JSON `[String: Any]`
    internal let json: [String: Any]?
    
}

// MARK: - CustomDebugStringConvertible
extension HTTPResponse: CustomDebugStringConvertible {
    
    var debugDescription: String {
        var description = response.debugDescription
        
        if let json = json {
            description += "\n\n" + json.debugDescription
        }
        
        return description
    }
    
}
