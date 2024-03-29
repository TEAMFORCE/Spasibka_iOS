//
//  Multiplexor.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.09.2022.
//

import StackNinja

// MARK: - Multiplexor

protocol Multiplexor: AnyObject {
   associatedtype Stock: InitProtocol

   var work: Out<Stock> { get }
   var stock: Stock { get set }
}

extension Multiplexor {
   func bind<T: Eventable, D>(event: KeyPath<T.Events, D?>,
                              of model: KeyPath<Self, T>,
                              to result: WritableKeyPath<Stock, D?>)
   {
      let model = self[keyPath: model]
      model.on(event, self) {
         $0.stock[keyPath: result] = $1
         $0.work.success($0.stock)
      }
   }
}
