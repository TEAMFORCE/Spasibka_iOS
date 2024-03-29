//
//  GetChallengeChainParticipantsUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.09.2023.
//

import ReactiveWorks

struct ChainParticipantsRequest {
   let organizationID: Int
   let chainID: Int
}

struct ChainParticipant: Decodable {
   let participantID: Int
   let participantPhoto: String?
   let participantName: String
   
   enum CodingKeys: String, CodingKey {
      case participantID = "participant_id"
      case participantPhoto = "participant_photo"
      case participantName = "participant_name"
   }
}

struct ChainParticipantsResponse: Decodable {
   let data: [ChainParticipant]
}

struct GetChainParticipantsUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker
   
   var work: In<ChainParticipantsRequest>.Out<ChainParticipantsResponse> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail { work.fail() }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetChallengeChainParticipants(
               headers: makeCookiedTokenHeader(token)) {
                  request.organizationID.toString
               } interpolateFunction2: {
                  request.chainID.toString
               }
            apiWorks
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let result = ChainParticipantsResponse(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: result)
               }
               .onFail { work.fail() }
         }
   } }
}
