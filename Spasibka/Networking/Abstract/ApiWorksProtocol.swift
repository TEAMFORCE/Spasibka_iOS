//
//  ApiWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import ReactiveWorks
import UIKit

protocol ApiWorksProtocol {
   func process(endpoint: EndpointProtocol) -> Out<ApiEngineResult>
   func processWithImage(endpoint: EndpointProtocol, image: UIImage) -> Out<ApiEngineResult>
   func processPUT(endpoint: EndpointProtocol) -> Out<ApiEngineResult>
   func processWithImages(endpoint: EndpointProtocol, images: [UIImage], names: [String]) ->
   Out<ApiEngineResult>
}
