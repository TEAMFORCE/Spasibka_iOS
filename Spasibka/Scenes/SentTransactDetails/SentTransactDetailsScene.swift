//
//  TransactDetailViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 10.08.2022.
//

import Alamofire
import StackNinja
import UIKit

enum TransactDetailsState {
   case sentTransaction(Transaction)
   case recievedTransaction(Transaction)
}

final class SentTransactDetailsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   ModalDoubleStackModel<Asset>,
   Asset,
   Transaction,
   Void
>, Scenarible {
   typealias State = StackState

   lazy var scenario = SentTransactDetailsScenario<Asset>(
      works: SentTransactDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: SentTransactDetailsEvents(
         inputTransaction: on(\.input)
      )
   )

   private lazy var transactUserInfoBlock = TransactUserBlockVM<Design>()
   private lazy var transactInfoBlock = TransactInfoBlockVM<Asset>()
   private lazy var hashTagBlock = HashTagsScrollModel<Design>()
      .hidden(true)

   override func start() {
      mainVM.bodyStack
         .alignment(.center)
         .set(.backColor(Design.color.background))
         .arrangedModels([
            Spacer(maxSize: 64),
            transactUserInfoBlock,
            Spacer(maxSize: 64),
         ])
      
      mainVM.footerStack
         .arrangedModels([
            hashTagBlock,
            Spacer(12),
            ScrollStackedModelY().arrangedModels(transactInfoBlock),
            Spacer(),
         ])

      mainVM.closeButton.on(\.didTap, self) {
         $0.dismiss()
      }
      
      scenario.configureAndStart()
      
      setState(.loading)
   }
}

enum SentTransactDetailsState {
   case initial(transaction: Transaction, isMy: Bool)
   case loading
}

extension SentTransactDetailsScene: StateMachine {
   func setState(_ state: SentTransactDetailsState) {
      
      switch state {
      case .loading:
         mainVM.bodyStack
            .arrangedModels(
               //Design.model.common.activityIndicatorSpaced
            )
         mainVM.footerStack
            .arrangedModels(
               Design.model.common.activityIndicatorSpaced
            )
         
      case let .initial(transaction, isMy):
         
         mainVM.bodyStack
            .alignment(.center)
            .set(.backColor(Design.color.background))
            .arrangedModels([
               Spacer(maxSize: 64),
               transactUserInfoBlock,
               Spacer(maxSize: 64),
            ])
         
         mainVM.footerStack
            .arrangedModels([
               hashTagBlock,
               Spacer(12),
               ScrollStackedModelY().arrangedModels(transactInfoBlock),
               Spacer(),
            ])
         
         if transaction.tags?.isEmpty == false {
            hashTagBlock.setup(transaction.tags)
            hashTagBlock.hidden(false)
         }
         
         switch isMy {
         case true:
            transactUserInfoBlock.setState(.sentTransaction(transaction))
            transactInfoBlock.setState(.sentTransaction(transaction))
         case false:
            transactUserInfoBlock.setState(.recievedTransaction(transaction))
            transactInfoBlock.setState(.recievedTransaction(transaction))
         }
      }
      
   }
}
