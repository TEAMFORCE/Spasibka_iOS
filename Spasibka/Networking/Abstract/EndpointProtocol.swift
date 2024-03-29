//
//  EndpointProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.06.2022.
//

import Foundation

protocol EndpointProtocol {
   var endPoint: String { get }

   var method: HTTPMethod { get }
   var headers: [String: String] { get }
   var body: [String: Any] { get }
   var jsonData: Data? { get }

   var interpolateFunction: (() -> String)? { get }
   var interpolateFunction2: (() -> String)? { get }
   var interpolateFunction3: (() -> String)? { get }
}

extension EndpointProtocol {
   var method: HTTPMethod { .get }
   var headers: [String: String] { [:] }
   var body: [String: Any] { [:] }
   var jsonData: Data? { nil }

   var interpolateFunction: (() -> String)? { nil }
   var interpolated: String { interpolateFunction?() ?? "" }
   
   var interpolateFunction2: (() -> String)? { nil }
   var interpolated2: String { interpolateFunction2?() ?? "" }
   
   var interpolateFunction3: (() -> String)? { nil }
   var interpolated3: String { interpolateFunction3?() ?? "" }
}
