//
//  GetTagByIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.09.2022.
//

import StackNinja

final class GetTagByIdApiWorker: BaseApiWorker<RequestWithId, Tag> {
   override func doAsync(work: Work<RequestWithId, Tag>) {
      guard
         let request = work.input
      else {
         work.fail()
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.TagById(id: String(request.id), headers: [
            Config.tokenHeaderKey: request.token,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let tags: Tag = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: tags)
         }
         .catch { _ in
            work.fail()
         }
   }
}
