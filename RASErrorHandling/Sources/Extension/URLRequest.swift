//
// URLRequest.swift
//
// Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

extension URLRequest {
    
    var debugDescription: String {
        var description = url!.debugDescription
        
        if let headers = allHTTPHeaderFields {
            description += "\n\n" + headers.debugDescription
        }
        
        if let body = httpBody {
            description += "\n\n" + body.debugDescription
        }
        
        return description
    }

}
