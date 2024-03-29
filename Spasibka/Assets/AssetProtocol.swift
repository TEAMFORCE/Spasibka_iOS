//
//  AssetProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.06.2022.
//

import StackNinja

protocol ServiceProtocol: InitProtocol {
   var apiEngine: ApiEngineProtocol { get }
   var apiWorks: ApiWorksProtocol { get }
   var safeStringStorage: StringStorageProtocol { get }
   var userDefaultsStorage: UserDefaultsStorageProtocol { get }
   var staticTextCache: StaticTextCacheProtocol.Type { get }
}

typealias ASP = AssetProtocol

protocol AssetProtocol: AssetRoot
   where
   Scene: ScenesProtocol,
   Service: ServiceProtocol,
   Design: DesignProtocol
{
   static var router: MainRouter<Self>? { get set }

   typealias Asset = Self
   typealias Text = Design.Text
}

extension AssetProtocol {
   static var apiUseCase: ApiUseCase<Asset> {
      .init()
   }

   static var safeStorageUseCase: StorageWorks<Asset> {
      .init()
   }

   static var userDefaultsWorks: UserDefaultsWorks<Asset> {
      .init()
   }
}


