//
//  Optional+Unwrap.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2022.
//

import Foundation

extension Optional where Wrapped == String {
   var unwrap: Wrapped { self ?? "" }
}

extension Optional where Wrapped == Bool {
   var unwrap: Wrapped { self ?? false }
}

extension Optional where Wrapped: Numeric {
   var unwrap: Wrapped { self ?? .zero }
}

extension Optional where Wrapped: Collection {
   var unwrap: Wrapped { self ?? [Wrapped]() as! Wrapped }
}

