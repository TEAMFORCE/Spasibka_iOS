//
//  LanguageWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2023.
//

import StackNinja

final class LanguageWorksStorage: InitClassProtocol {}

final class LanguageWorks<Asset: ASP>: BaseWorks<LanguageWorksStorage, Asset> {
   lazy var apiUseCase: ApiUseCase<Asset> = .init()
   let storageUseCase = Asset.safeStorageUseCase
   private lazy var userDefaults = Asset.userDefaultsWorks
   
   var changeLanguage: In<AppLanguages> { .init { [weak self] work in
      guard let self, let input = work.input else { work.fail(); return }
      
      let info: [String : String] = ["language" : input.rawValue]
      
      self.storageUseCase.getCurrentProfileId
         .doAsync()
         .doMap {
            UpdateProfileRequest(token: "",
                                 id: $0.toInt ?? -1,
                                 info: info)
         }
         .doNext(self.apiUseCase.updateProfile)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
      
   }.retainBy(retainer) }
}
