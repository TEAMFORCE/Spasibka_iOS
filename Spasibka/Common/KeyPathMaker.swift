//
//  KeyPathMaker.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.08.2022.
//

import Foundation

protocol KeyPathMaker {
   associatedtype Key
   associatedtype Result

   func make(_ keypath: KeyPath<Self, Key>) -> Result
}
