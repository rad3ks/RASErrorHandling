//
// JSONDecodingError.swift
//
// Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

/// Defines data to json decoding error
///
/// - missingBody: response body was missing when trying to decode
/// - unexpectedFormat: json was of unexpected format. Error contains expected `JSONFormat` - allowed `.array` or `.dictionary`
/// - serialization: serialization failed due to associated error
internal enum JSONDecodingError: Error {
    case missingBody
    case unexpectedFormat(JSONFormat)
    case serialization(Error)
}
