//
//  SearchUserApiModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.07.2022.
//

import Foundation
import StackNinja

struct SearchUserRequest {
  let data: String
  let token: String
  let csrfToken: String
}

struct SearchUserResult {
  let users: [FoundUser]
}

struct FoundUser: Codable {
  let userId: Int
  let tgName: String?
  let name: String?
  let surname: String?
  let photo: String?

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case tgName = "tg_name"
    case name
    case surname
    case photo
  }
}

struct SearchUserResponse: Decodable {
  var foundUsers: [FoundUser]

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    foundUsers = try container.decode([FoundUser].self) // Decode just first element
  }
}

final class SearchUserApiWorker: BaseApiWorker<SearchUserRequest, [FoundUser]> {
  //
  override func doAsync(work: Work<SearchUserRequest, [FoundUser]>) {
    let cookieName = "csrftoken"

    guard
      let searchRequest = work.input,
      let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
    else {
      print("No csrf cookie")
      return
    }

    apiEngine?
      .process(endpoint:
        SpasibkaEndpoints.SearchUser(
          body: ["data": searchRequest.data],
          headers: [
            Config.tokenHeaderKey: searchRequest.token,
            "X-CSRFToken": cookie.value
          ]))
      .done { result in
        let decoder = DataToDecodableParser()

        guard
          let data = result.data,
          let resultBody: [FoundUser] = decoder.parse(data)
        else {
          work.fail()
          return
        }

        print(resultBody)
        work.success(result: resultBody)
      }
      .catch { _ in
        work.fail()
      }
  }
}
