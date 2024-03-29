//
//  TagsDiagramWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2022.
//

import StackNinja

protocol TagsDiagramStorageProtocol: AnyObject, InitProtocol {
   var tagsPercents: [UserStat] { get set }
}

protocol TagDiagramsWorksProtocol: StoringWorksProtocol, Assetable where
   Asset: AssetProtocol,
   Store: TagsDiagramStorageProtocol
{
   var apiUseCase: ApiUseCase<Asset> { get }
   //
   var loadTagPercents: Work<Void, Void> { get }
   //
   var getTagsPercentsData: Work<Void, [UserStat]> { get }
}

extension TagDiagramsWorksProtocol {
   var loadTagPercents: Work<Void, Void> { .init { [weak self] work in

      self?.apiUseCase.getUserStats
         .doAsync()
         .onSuccess {
            Self.store.tagsPercents = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var getTagsPercentsData: Work<Void, [UserStat]> { .init { work in
      let tagsPercents = Self.store.tagsPercents
      guard !tagsPercents.isEmpty else {
         work.fail()
         return
      }

      work.success(tagsPercents)
   } }
}
