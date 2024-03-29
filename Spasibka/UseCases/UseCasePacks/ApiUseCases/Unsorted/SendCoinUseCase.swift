//
//  SendCoinUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 03.08.2022.
//

import Foundation
import StackNinja

struct SendCoinUseCase: UseCaseProtocol {
   let sendCoinApiModel: SendCoinApiWorker

   var work: Work<SendCoinRequest, Void> {
      sendCoinApiModel.work
   }
}
