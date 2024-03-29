//
//  ChallengeResCancelWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.10.2022.
//

import StackNinja
import UIKit

final class ChallengeResCancelStore: InitProtocol {
   var inputReasonText = ""
   var isCorrectReasonInput = false

   var resultId: Int?
}

final class ChallengeResCancelWorks<Asset: AssetProtocol>: BaseWorks<ChallengeResCancelStore, Asset> {
   private lazy var reasonInputParser = ReasonCheckerModel()
   private lazy var apiUseCase = Asset.apiUseCase

   var saveInput: Work<Int, Int> { .init { work in
      guard let input = work.input else { return }
      Self.store.resultId = input
   
      work.success(input)
   }.retainBy(retainer) }

   var reasonInputParsing: Work<String, String> { .init { [weak self] work in
      self?.reasonInputParser.work
         .retainBy(self?.retainer)
         .doAsync(work.input)
         .onSuccess {
            Self.store.inputReasonText = $0
            Self.store.isCorrectReasonInput = true
            work.success(result: $0)
         }
         .onFail { (text: String) in
            Self.store.inputReasonText = ""
            Self.store.isCorrectReasonInput = false
            work.fail(text)
         }
   } }
   
   var rejectReport: Work<Void, Void> { .init { [weak self] work in
      guard
         let id = Self.store.resultId
      else {
         work.fail()
         return
      }
      
      let request = CheckReportRequestBody(
         id: id,
         state: CheckReportRequestBody.State.D,
         text: Self.store.inputReasonText
      )
      
      self?.apiUseCase.checkChallengeReport
         .doAsync(request)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}
