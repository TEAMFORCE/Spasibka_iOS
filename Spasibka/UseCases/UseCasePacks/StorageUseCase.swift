//
//  StorageUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.08.2022.
//

import StackNinja

protocol CurrentUserStorageWorksProtocol: WorkBasket, Assetable where Asset: AssetProtocol {}

extension CurrentUserStorageWorksProtocol {
   var saveCurrentUserName: SaveCurrentUserUseCase.WRK {
      SaveCurrentUserUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }

   var getCurrentUserName: GetCurrentUserUseCase.WRK {
      GetCurrentUserUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }

   var saveCurrentUserId: SaveCurrentUserIdUseCase.WRK {
      SaveCurrentUserUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }

   var getCurrentUserId: GetCurrentUserIdUseCase.WRK {
      GetCurrentUserIdUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }
   
   var getCurrentProfileId: GetCurrentProfileIdUseCase.WRK {
      GetCurrentProfileIdUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }
   
   var getCurrentUserRole: GetCurrentUserRoleUseCase.WRK {
      GetCurrentUserRoleUseCase(safeStringStorage: Asset.service.safeStringStorage)
         .retainedWork(retainer)
   }

   var loadToken: LoadTokenUseCase.WRK {
      LoadTokenUseCase(loadTokenWorker: loadTokenWorker)
         .retainedWork(retainer)
   }

   var loadCsrfToken: LoadCsrfTokenUseCase.WRK {
      LoadCsrfTokenUseCase(safeStringStorage: safeStringStorageWorker)
         .retainedWork(retainer)
   }

   var loadBothTokens: LoadBothTokensUseCase.WRK {
      LoadBothTokensUseCase(safeStringStorage: safeStringStorageWorker)
         .retainedWork(retainer)
   }
}

extension StorageWorks: CurrentUserStorageWorksProtocol {}

struct StorageWorks<Asset: AssetProtocol>: Assetable, WorkBasket {
   let retainer = Retainer()
}

private extension CurrentUserStorageWorksProtocol {
   
   var safeStringStorageWorker: StringStorageWorker {
      StringStorageWorker(engine: Asset.service.safeStringStorage)
   }
   
   var loadTokenWorker: LoadTokenWorker {
      .init(safeStringStorage: safeStringStorageWorker)
   }
}
