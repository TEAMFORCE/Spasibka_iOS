//
//  FeedbackWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 03.08.2023.
//

import StackNinja

//final class FeedbackWorksStorage: InitClassProtocol {}
//
//final class FeedbackWorks<Asset: ASP>: BaseWorks<FeedbackWorksStorage, Asset> {
//   lazy var apiUseCase: ApiUseCase<Asset> = .init()
//
//   var getLicenseEnd: Work<Void, String> { .init { [weak self] work in
//      self?.apiUseCase.getOrganizationSettings
//         .doAsync()
//         .onSuccess {
//            if let licence = $0.licenseEnd {
//               work.success(licence)
//            } else {
//               work.fail()
//            }
//         }
//         .onFail { work.fail() }
//   }.retainBy(retainer) }
//}
