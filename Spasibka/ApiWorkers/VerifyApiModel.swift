//
//  VerifyApiModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import Foundation
import StackNinja

struct VerifyRequest {
   let smsCode: String

   let xId: String?
   let xCode: String?
   let xEmail: String?
   let xTelegram: String?

   let organizationId: String?
   let sharingKey: String?

   init (
      smsCode: String,
      xId: String? = nil,
      xCode: String? = nil,
      xEmail: String? = nil,
      xTelegram: String? = nil,
      organizationId: String? = nil,
      sharingKey: String? = nil
   ) {
      self.smsCode = smsCode
      self.xId = xId
      self.xCode = xCode
      self.xEmail = xEmail
      self.xTelegram = xTelegram
      self.organizationId = organizationId
      self.sharingKey = sharingKey
   }
}

struct VerifyResult {
   let type: String //  "authresult",
   let isSuccess: Bool //  false
}

struct VerifyResultBody: Codable {
   let type: String
   let isSuccess: Bool
   let token: String
   let sessionId: String

   enum CodingKeys: String, CodingKey {
      case sessionId = "sessionid"
      case isSuccess = "is_success"
      case type
      case token
   }
}

final class VerifyApiModel: BaseApiWorker<VerifyRequest, VerifyResultBody> {
   override func doAsync(work: Work<VerifyRequest, VerifyResultBody>) {
      let verifyRequest = work.in

      var body = ["type": "authcode",
                  "code": verifyRequest.smsCode]

      if let xId = verifyRequest.xId {
         body["x-id"] = xId
      }
      if let xCode = verifyRequest.xCode {
         body["x-code"] = xCode
      }
      if let xEmail = verifyRequest.xEmail {
         body["x-email"] = xEmail
      }
      if let xTelegram = verifyRequest.xTelegram {
         body["x-telegram"] = xTelegram
      }
      if let orgId = verifyRequest.organizationId {
         body["organization_id"] = orgId
      }
      if let sharingKey = verifyRequest.sharingKey {
         body["shared_key"] = sharingKey
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.VerifyEndpoint(
            body: body
         ))
         .done { result in
            let decoder = DataToDecodableParser()

            guard
               let data = result.data,
               let resultBody: VerifyResultBody = decoder.parse(data)
            else {
               work.fail()
               return
            }

            work.success(result: resultBody)
         }
         .catch { _ in
            work.fail()
         }
   }
}
