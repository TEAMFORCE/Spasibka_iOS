//
//  GetFileUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.02.2023.
//

import Foundation
import StackNinja
import PDFKit

struct GetFileUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getFileApiWorker: GetFileApiWorker

   var work: Work<String, PDFDocument> {
      Work<String, PDFDocument>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let fileName = work.input else { return nil }
               return ($0, fileName)
            }
            .doNext(getFileApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
