//
//  GetInviteLink.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import ReactiveWorks

struct InviteResponseBody: Decodable {
   let inviteLink: String

   enum CodingKeys: String, CodingKey {
      case inviteLink = "invite_link"
   }
}

struct GetInviteLinkUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Out<InviteResponseBody> { .init { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let endpoint = SpasibkaEndpoints.GetInviteLink(
                  headers: makeCookiedTokenHeader(token)
               )

               self.apiEngine
                  .process(endpoint: endpoint)
                  .onSuccess { result in
                     guard
                        let result: InviteResponseBody = .init(result.data)
                     else {
                        work.fail()
                        return
                     }
                     work.success(result: result)
                  }
                  .onFail {
                     work.fail()
                  }
            }
      }
   }
}

