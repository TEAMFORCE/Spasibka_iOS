//
//  PayloadedWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

protocol PayloadWorkStore: InitClassProtocol {
   associatedtype Payload

   var payload: Payload? { get set }
}

protocol PayloadWorksProtocol: StoringWorksProtocol where Store: PayloadWorkStore {
   var storePayload: MapInOut<Store.Payload> { get }
}

class BasePayloadWorks<Store: PayloadWorkStore, Asset: AssetRoot>: BaseWorks<Store, Asset>,
                                                                   PayloadWorksProtocol {
   
   var storePayload: MapInOut<Store.Payload> { .init {
      Self.store.payload = $0
      return $0
   }}
   
   var getPayload: MapOut<Store.Payload> { .init {
      Self.store.payload
   }}
}
