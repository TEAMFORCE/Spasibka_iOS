//
//  SetupProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.09.2022.
//

protocol SetupProtocol {
   associatedtype Params
   
   func setup(_ data: Params)
}
