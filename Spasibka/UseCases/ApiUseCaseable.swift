//
//  ApiUseCaseable.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.12.2022.
//

import Foundation

protocol ApiUseCaseable {
    associatedtype Asset: ASP
    var apiUseCase: ApiUseCase<Asset> { get }
}
