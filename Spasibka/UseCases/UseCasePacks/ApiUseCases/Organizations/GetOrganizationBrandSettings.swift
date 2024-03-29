//
//  GetOrganizationBrandSettings.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.06.2023.
//

import ReactiveWorks

struct GetOrgBrandSettingsUseCase: UseCaseProtocol {
   typealias In = Int
   typealias Out = OrganizationBrandSettings

   let apiEngine: ApiWorksProtocol
   let stringStorage: StringStorageWorker

   var work: WRK { .init { work in
      stringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            guard let orgId = work.input else {
               work.fail()
               return
            }
            let endpoint = SpasibkaEndpoints.GetOrganizationBrandSettings(
               headers: makeCookiedTokenHeader(token)
            ) {
               "\(orgId)"
            }

            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let result: OrganizationBrandSettings = .init(result.data)
                  else {
                     work.fail()
                     return
                  }
                  print(result)
                  work.success(result: result)
               }
               .onFail {
                  work.fail()
               }
         }
   }
   }
}
