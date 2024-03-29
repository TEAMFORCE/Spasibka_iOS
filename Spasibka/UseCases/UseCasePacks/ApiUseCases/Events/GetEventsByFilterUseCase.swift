//
//  GetInviteLink.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import Foundation
import StackNinja

enum FeedEventSelector: String {
   case transaction = "T"
   case challenge = "Q"
   case winner = "R"
   case market = "P"
}

struct FeedEvent: Codable {
   let id: Int
   let time: String?
   let text: String?
   let endAt: String?
   var userLiked: Bool?
   let mainlink: String?
   let icon: String?
   let header: String?
   let photos: [String]?
   var likesAmount: Int?
   let commentsAmount: Int?
   let tags: [Tag]?
   let selector: String?
   let textIcon: String?

   var eventSelectorType: FeedEventSelector? {
      FeedEventSelector(rawValue: selector ?? "")
   }

   private enum CodingKeys: String, CodingKey {
      case id,
           time,
           text,
           endAt = "end_at",
           userLiked = "user_liked",
           mainlink,
           icon,
           header,
           photos,
           likesAmount = "likes_amount",
           commentsAmount = "comments_amount",
           tags,
           selector,
           textIcon = "text_icon"
   }

   struct Tag: Codable {
      let tagId: Int
      let name: String

      private enum CodingKeys: String, CodingKey {
         case tagId = "tag_id",
              name
      }
   }
}

struct FeedFilterEvent: Codable, Hashable {
   let id: Int
   let name: String
   let on: Bool
}

struct FeedFilter: Codable {
   let eventTypes: [FeedFilterEvent]

   private enum CodingKeys: String, CodingKey {
      case eventTypes = "eventtypes"
   }
}

struct EventsRequest {
   let filters: [Int]
}

extension EventsRequest {
   var filtersString: String { filters.map { "filters=\($0)" }.joined(separator: "&") }
}

struct EventsResponse: Codable {
   let filter: FeedFilter
   let data: [FeedEvent]

   private enum CodingKeys: String, CodingKey {
      case filter,
           data
   }

   struct Tag: Codable {
      let tagId: Int
      let name: String

      private enum CodingKeys: String, CodingKey {
         case tagId = "tag_id",
              name
      }
   }
}

extension PaginationWithRequest {
   var pageBody: [String: Any] {
      [
         "offset": offset,
         "limit": limit,
      ]
   }
}

struct GetEventsByFilterUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<EventsRequest>, PaginationResponse<FeedEvent, FeedFilter>> { .init { work in
      let input = work.in
      let request = input.request
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetEventsByFilter(headers: makeCookiedTokenHeader(token)) {
               "?limit=\(input.limit)&offset=\(input.offset)"
                  + (request.filtersString.isEmpty ? "" : ("&" + request.filtersString))
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let result = EventsResponse(result.data)
                  else {
                     work.fail()
                     return
                  }

                  work.success(result: .init(array: result.data, data: result.filter))
               }
               .onFail {
                  work.fail()
               }
         }
   }}
}
