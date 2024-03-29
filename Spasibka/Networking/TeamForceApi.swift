//
//  SpasibkaApi.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.04.2022.
//

import Foundation
import PromiseKit

typealias SpasibkaResult<T> = Swift.Result<T, SpasibkaApiError>

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum SpasibkaApiError: Error {
    case wrongEndpoint
    case jsonParsing
    case error(Error)
}

struct ApiResult<T: Decodable> {
    let data: T
    let response: URLResponse?
}

extension URLResponse {
    func headerValueFor(_ key: String) -> String? {
        guard
            let value = (self as? HTTPURLResponse)?.value(forHTTPHeaderField: key)
        else {
            return nil
        }

        print("Header Value for Key (\(key)): ", value)
        return value
    }
}
