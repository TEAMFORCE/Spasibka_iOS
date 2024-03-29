//
//  GetFileApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.02.2023.
//

import Foundation
import StackNinja
import PDFKit

final class GetFileApiWorker: BaseApiWorker<(String, String), PDFDocument> {
   override func doAsync(work: Wrk) {
      guard
         let input = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetFile(
            fileName: input.1,
            headers: [
               Config.tokenHeaderKey: input.0
            ]))
         .done { result in
            guard
               let data = result.data,
               let pdf = PDFDocument(data: data)
            else {
               work.fail()
               return
            }
            work.success(result: pdf)
         }
         .catch { _ in
            work.fail()
         }
   }
}
