//
//  GetOrgSettingsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.12.2022.
//

import StackNinja

struct GetOrgSettingsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getOrgSettingsApiWorker: GetOrgSettingsApiWorker

   var work: Work<Void, OrganizationSettings> {
      Work<Void, OrganizationSettings>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               $0
            }
            .doNext(getOrgSettingsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
