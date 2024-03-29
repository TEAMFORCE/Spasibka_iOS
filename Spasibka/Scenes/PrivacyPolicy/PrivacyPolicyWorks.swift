//
//  PrivacyPolicyWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.12.2022.
//

import PDFKit
import StackNinja

final class PrivacyPolicyTemp: InitClassProtocol {}

final class PrivacyPolicyWorks<Asset: ASP>: BaseWorks<PrivacyPolicyTemp, Asset> {

   private lazy var apiUseCase = Asset.apiUseCase
   
   var loadPdfPolicyForName: Work<String, PDFDocument> { .init { [weak self] work in
      guard let input = work.input else { work.fail(); return }
      var fileName = "terms_of_use.pdf"
      switch input {
      case "privacyPolicy":
         fileName = "policy_mobile.pdf"
      default:
         fileName = "terms_of_use.pdf"
      }
      
      self?.apiUseCase.getFile
         .doAsync(fileName)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
      
   }.retainBy(retainer) }
}
