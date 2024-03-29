//
//  GetProfileById.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.09.2022.
//

import StackNinja

final class GetProfileByIdApiWorker: BaseApiWorker<RequestWithId, UserData> {
   override func doAsync(work: Work<RequestWithId, UserData>) {
      guard
         let request = work.input
      else {
         work.fail()
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.ProfileById(id: String(request.id), headers: [
            Config.tokenHeaderKey: request.token,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let profile: UserData = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: profile)
         }
         .catch { _ in
            work.fail()
         }
   }
}
