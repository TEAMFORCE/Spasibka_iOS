//
//  InputCheckers.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.08.2022.
//

import Foundation
import StackNinja

// MARK: - TelegramNickCheckerModel

final class TelegramNickCheckerModel {}

extension TelegramNickCheckerModel: WorkerProtocol {
   func doAsync(work: Work<String, String>) {
      if work.unsafeInput.count > 3 {
         work.success(result: work.unsafeInput)
      } else {
         work.fail(work.unsafeInput)
      }
   }
}

// MARK: - SmsCodeCheckerModel

final class SmsCodeCheckerModel {
   private var maxDigits: Int = 4

   convenience init(maxDigits: Int) {
      self.init()
      self.maxDigits = maxDigits
   }
}

extension SmsCodeCheckerModel: WorkerProtocol {
   //
   func doAsync(work: Work<String, String>) {
      let text = work.unsafeInput

      if work.unsafeInput.count >= maxDigits {
         let text = text.dropLast(text.count - maxDigits)
         work.success(result: String(text))
      } else {
         work.fail(text)
      }
   }
}

// MARK: - CoinInputCheckerModel

final class CoinInputCheckerModel {
   private var maxDigits: Int = 8

   convenience init(maxDigits: Int) {
      self.init()
      self.maxDigits = maxDigits
   }
}

extension CoinInputCheckerModel: WorkerProtocol {
   //
   func doAsync(work: Work<String, String>) {
      let text = work.unsafeInput

      if text.count > 0 {
         var textToSend = text
         if text.count >= maxDigits {
            textToSend = String(text.dropLast(text.count - maxDigits))
         }

         !text.isNumber ? work.fail(text) : work.success(result: textToSend)
      } else {
         work.fail(text)
      }
   }
}

// MARK: - ReasonCheckerModel

final class ReasonCheckerModel {
   private var maxDigits: Int = 8

   convenience init(maxDigits: Int) {
      self.init()
      self.maxDigits = maxDigits
   }
}

extension ReasonCheckerModel: WorkerProtocol {
   func doAsync(work: Work<String, String>) {
      let text = work.unsafeInput

      if text.count > 0 {
         work.success(result: text)
      } else {
         work.fail(text)
      }
   }
}
