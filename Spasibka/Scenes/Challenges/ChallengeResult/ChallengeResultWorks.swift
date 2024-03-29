//
//  ChallengeResultWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.10.2022.
//

import StackNinja
import UIKit

final class ChallengeResultStore: InitProtocol, ImageStorage {
   var indexes: [Int] = []
   
   var images: [UIImage] = []

   var inputReasonText = ""
   var isCorrectReasonInput = false

   var challengeId: Int?
}

final class ChallengeResultWorks<Asset: AssetProtocol>: BaseWorks<ChallengeResultStore, Asset>, InputTextCachableWorks {
   private lazy var reasonInputParser = ReasonCheckerModel()
   private lazy var apiUseCase = Asset.apiUseCase

   var saveId: Work<Int, Int> { .init { [weak self] work in
      guard let id = work.input else { return }
      
      Self.store.challengeId = id
      self?.inputTextCacher.setKey("ChallengeResultInput \(id)")
      
      work.success(id)
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

   var createChallengeReport: Work<Void, Void> { .init { [weak self] work in
      var resizedImages: [UIImage]?
      if Self.store.images.count > 0 {
         resizedImages = []
      }
      for image in Self.store.images {
         resizedImages?.append(image.sideLengthLimited(to: Config.imageSendSize))
      }
      
      
      guard let id = Self.store.challengeId else { return }
      let report = ChallengeReportBody(challengeId: id,
                                       text: Self.store.inputReasonText,
                                       photo: resizedImages)
      self?.apiUseCase.createChallengeReport
         .doAsync(report)
         .onSuccess {
            self?.inputTextCacher.clearCache()
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   lazy var inputTextCacher = TextCachableWork(cache: Asset.service.staticTextCache) 
}

// Добавляем Image Works
extension ChallengeResultWorks: ImageWorks {}
