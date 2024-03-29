//
//  ApiEngineProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.06.2022.
//

import Foundation
import PromiseKit
import UIKit

// deprecate this
@available(*, deprecated, message: "Use ApiWorksProtocol instead")
protocol ApiEngineProtocol {
   func process(endpoint: EndpointProtocol) -> Promise<ApiEngineResult>
   func processWithImage(endpoint: EndpointProtocol, image: UIImage) -> Promise<ApiEngineResult>
   func processPUT(endpoint: EndpointProtocol) -> Promise<ApiEngineResult>
   func processWithImages(endpoint: EndpointProtocol, images: [UIImage], names: [String]) ->
      Promise<ApiEngineResult>
}

