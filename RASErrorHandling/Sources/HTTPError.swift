//
// HTTPError.swift
//
// Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation
import Result
import ReactiveSwift

/// Represents HTTP error response status code with associated http transaction (request & response)
///
/// - badRequest: 400
/// - unauthorized: 401
/// - notFound: 404
/// - internalServerError: 500
/// - badResponse: response from server is incorrect - reason may be specified in associated `Error`
/// - unclassified: Unclassified network error
internal enum HTTPError: Error {
    case badRequest(HTTPTransaction)
    case unauthorized(HTTPTransaction)
    case notFound(HTTPTransaction)
    case internalServerError(HTTPTransaction)
    case badResponse(Error?)
    case unclassified(HTTPTransaction)
}

// MARK: - Convienience initializers
internal extension HTTPError {
    
    /// Convenience init for creating `HTTPError` out of `AnyError` related to http operation failure
    ///
    /// - Parameter error: any error
    init(error: AnyError) {
        self = {
            guard let httpError = error.error as? HTTPError else {
                return .badResponse(error)
            }
            return httpError
        }()
    }
    
}

// MARK: - CustomStringConvertible
extension HTTPError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .badRequest: return "bad request"
        case .unauthorized: return "unauthorized"
        case .notFound: return "not found"
        case .internalServerError: return "internal server error"
        case .badResponse: return "bad response"
        case .unclassified: return "unclassified"
        }
    }
    
}
