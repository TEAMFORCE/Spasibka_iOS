//
//  EventsEndpoints.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.06.2022.
//

import Foundation

// Api Endpoints
enum SpasibkaEndpoints {
   static var urlBase: String { Config.urlBase }
   static var urlMediaBase: String { urlBase + "/media/" }

   static func convertToImageUrl(_ urlString: String) -> String {
      urlBase + urlString
   }

   static func tryConvertToImageUrl(_ urlString: String?) -> String? {
      guard let urlString = urlString else { return nil }

      return urlBase + urlString
   }

   static func convertToFullImageUrl(_ urlString: String) -> String {
      urlBase + removeThumbSuffix(urlString)
   }

   static func removeThumbSuffix(_ urlString: String) -> String {
      urlString.replacingOccurrences(of: "_thumb", with: "")
   }

   //
   struct AuthEndpoint: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/auth/" }

      let body: [String: Any]
   }

   struct VerifyEndpoint: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/verify/" }

      let body: [String: Any]

      let headers: [String: String] = [:]
   }

   struct ProfileEndpoint: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/user/profile/" }

      let headers: [String: String]
   }

   struct BalanceEndpoint: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/user/balance/" }

      let headers: [String: String]
   }

   struct SearchUser: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/search-user/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct Logout: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/logout/" }
   }

   struct SendCoin: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/send-coins/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct GetTransactions: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/user/transactions/"

      let headers: [String: String]

      init(headers: [String: String],
           sentOnly: Bool? = nil,
           recievedOnly: Bool? = nil,
           offset: Int,
           limit: Int)
      {
         self.headers = headers
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         if sentOnly == true {
            endPoint += "&sent_only=1"
         }
         if recievedOnly == true {
            endPoint += "&received_only=1"
         }
      }
   }

   struct GetTransactionById: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/user/transactions/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct UsersList: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/users-list/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct Feed: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/feed/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct Periods: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/periods/" }

      let headers: [String: String]
   }

   struct StatPeriodById: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/user/stat/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct GetTransactionByPeriod: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/user/transactions-by-period/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct CancelTransaction: EndpointProtocol {
      //
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/cancel-transaction/"

      var headers: [String: String]

      var body: [String: Any]

      init(id: String, headers: [String: String], body: [String: Any]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.body = body
      }
   }

   struct GetCurrentPeriod: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/get-current-period/" }

      let headers: [String: String]
   }

   struct GetPeriodByDate: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-period-by-date/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct GetPeriodsFromDate: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-periods/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct UpdateProfileImage: EndpointProtocol {
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/update-profile-image/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct UpdateProfile: EndpointProtocol {
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/update-profile-by-user/"

      var body: [String: Any]

      var headers: [String: String]

      init(id: String, headers: [String: String], body: [String: Any]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.body = body
      }
   }

   struct UpdateContact: EndpointProtocol {
      let method = HTTPMethod.patch

      var endPoint: String = urlBase + "/update-contact-by-user/"

      var body: [String: Any]

      var headers: [String: String]

      init(id: String, headers: [String: String], body: [String: Any]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.body = body
      }
   }

   struct CreateContact: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/create-contact-by-user/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct CreateFewContacts: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/create-few-contacts/" }

      let jsonData: Data?

      let headers: [String: String]
   }

   struct Tags: EndpointProtocol {
      var endPoint: String { urlBase + "/tags/" }

      let headers: [String: String]
   }

   struct TagById: EndpointProtocol {
      var endPoint: String = urlBase + "/tags/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct ProfileById: EndpointProtocol {
      var endPoint: String = urlBase + "/profile/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   @available(*, deprecated, message: "Use PressLike")
   struct PressLikeOld: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/press-like/" }

      var headers: [String: String]

      let jsonData: Data?
   }

   struct PressLike: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/press-like/" }

      var headers: [String: String]

      var body: [String : Any]
   }

   struct GetLikesCommentsStat: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-likes-comments-statistics/" }

      var headers: [String: String]

      let jsonData: Data?
   }

   struct GetComments: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-comments/" }

      var headers: [String: String]

      let jsonData: Data?
   }

   struct CreateComment: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/create-comment/" }

      var headers: [String: String]

      var body: [String: Any]
   }

   struct UpdateComment: EndpointProtocol {
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/update-comment/"

      var body: [String: Any]

      var headers: [String: String]

      init(id: String, headers: [String: String], body: [String: Any]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.body = body
      }
   }

   struct DeleteComment: EndpointProtocol {
      let method = HTTPMethod.delete

      var endPoint: String = urlBase + "/delete-comment/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct GetLikesByTransaction: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-likes-by-transaction/" }

      var headers: [String: String]

      let jsonData: Data?
   }

   struct GetChallenges: EndpointProtocol {
      var endPoint: String { urlBase + "/api/challenges/\(interpolated)" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
   }
   
   struct GetChallengeById: EndpointProtocol {
      var endPoint: String = urlBase + "/challenges/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct GetChallengeContenders: EndpointProtocol {
      var endPoint: String = urlBase + "/challenge-contenders/"

      let headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct CreateChallenge: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/create-challenge/" }

      let headers: [String: String]

      var body: [String: Any]
   }

   struct CreateChallengeGet: EndpointProtocol {
      var endPoint: String { urlBase + "/create-challenge/" }

      let headers: [String: String]

      // var body: [String : Any]
   }

   struct ChallengeWinners: EndpointProtocol {
      var endPoint: String = urlBase + "/challenge-winners/"

      let headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct CreateChallengeReport: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/create-challenge-report/" }

      let headers: [String: String]

      let body: [String: Any]
   }

   struct CheckChallengeReport: EndpointProtocol {
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/check-challenge-report/"

      let headers: [String: String]

      let jsonData: Data?

      init(id: String, headers: [String: String], jsonData: Data?) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.jsonData = jsonData
      }
   }

   struct SendCoinSettings: EndpointProtocol {
      var endPoint: String { urlBase + "/send-coins-settings/" }

      let headers: [String: String]
   }

   struct ChallengeResult: EndpointProtocol {
      var endPoint: String = urlBase + "/challenge-result/"

      let headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct ChallengeWinnersReports: EndpointProtocol {
      var endPoint: String = urlBase + "/challenge-winners-reports/"

      let headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct ChallengeReport: EndpointProtocol {
      var endPoint: String = urlBase + "/challenge-report/"

      let headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct Events: EndpointProtocol {
      var endPoint: String = urlBase + "/events/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct EventsTransactions: EndpointProtocol {
      var endPoint: String = urlBase + "/events/transactions/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct EventsWinners: EndpointProtocol {
      var endPoint: String = urlBase + "/events/winners/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct EventsChallenges: EndpointProtocol {
      var endPoint: String = urlBase + "/events/challenges/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct EventsTransactById: EndpointProtocol {
      var endPoint: String = urlBase + "/events/transactions/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct SetFcmToken: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/set-fcm-token/" }

      var headers: [String: String]

      let body: [String: Any]
   }

   struct RemoveFcmToken: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/remove-fcm-token/" }

      let headers: [String: String]

      let body: [String: Any]
   }

   struct Notifications: EndpointProtocol {
      var endPoint: String = urlBase + "/notifications/"

      let headers: [String: String]

      init(offset: Int, limit: Int, headers: [String : String]) {
         endPoint = endPoint + "?offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }

   struct NotificationReadWithId: EndpointProtocol {
      let method = HTTPMethod.put

      var endPoint: String = urlBase + "/notifications/"

      let headers: [String: String]

      let jsonData: Data?

      init(id: String, headers: [String: String], jsonData: Data?) {
         endPoint = endPoint + id + "/"
         self.headers = headers
         self.jsonData = jsonData
      }
   }

   struct NotificationsAmount: EndpointProtocol {
      var endPoint: String { urlBase + "/notifications/unread/amount/" }

      let headers: [String: String]
   }

   struct UserOrganizations: EndpointProtocol {
      var endPoint: String { urlBase + "/user/organizations/" }

      let headers: [String: String]
   }

   struct ChangeOrganization: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/user/change-organization/" }

      let headers: [String: String]

      let jsonData: Data?
   }

   struct ChangeOrganizationVerifyEndpoint: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/user/change-organization/verify/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct ChooseOrganizationEndpoint: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/choose-organization/" }

      let body: [String: Any]

      let headers: [String: String]
   }

   struct GetLikes: EndpointProtocol {
      //
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/get-likes/" }

      var headers: [String: String]

      let jsonData: Data?
   }

   struct CloseChallenge: EndpointProtocol {
      //
      var endPoint: String = urlBase + "/close-challenge/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + id + "/"
         self.headers = headers
      }
   }

   struct GetUserStats: EndpointProtocol {
      //
      let endPoint: String = urlBase + "/user/profile/stats/?recipient_only=1"

      var headers: [String: String]
   }
   
   struct GetOrganizationSettings: EndpointProtocol {
      //
      let endPoint: String = urlBase + "/organization/settings/"
      
      var headers: [String : String]
   }

   struct GetOrganizationBrandSettings: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/organizations/\(interpolated)/brand/" }

      let headers: [String : String]

      let interpolateFunction: (() -> String)?
   }

   struct GetLastPeriodRate: EndpointProtocol {
      //
      var endPoint: String { urlBase + "/last-period-rate/" }

      var headers: [String : String]
   }
   
   struct GetMarketItems2: EndpointProtocol {
      var endPoint: String { urlBase + "/market/\(interpolated)" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
   }
   
   struct GetMarketItems: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      init(id: Int,
           contain: String? = nil,
           minPrice: Int? = nil,
           maxPrice: Int? = nil,
           category: Int? = nil,
           headers: [String : String]
      ) {
         endPoint += "\(id)/offers/"
         var sign = "?"
         self.headers = headers
         if let category = category {
            endPoint += "\(sign)category=\(category)"
            sign = "&"
         }
         if let contain = contain {
            endPoint += "\(sign)contain=\(contain)"
            sign = "&"
         }
         if let minPrice = minPrice {
            endPoint += "\(sign)min_price=\(minPrice)"
            sign = "&"
         }
         if let maxPrice = maxPrice {
            endPoint += "\(sign)max_price=\(maxPrice)"
         }
         endPoint = endPoint.encodeUrl
      }
   }
   
   struct GetMarketItemById: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      init(marketId: Int, id: Int, headers: [String: String]) {
         endPoint += "\(marketId)/offers/"
         endPoint += "\(id)/"
         self.headers = headers
      }
   }
   
   struct GetMarketCategories: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String = urlBase + "/market/" 
      
      var headers: [String : String]
      
      init(marketId: Int, headers: [String : String]) {
         endPoint += "\(marketId)/categories/"
         self.headers = headers
      }
   }
   
   struct AddToCart: EndpointProtocol {
      //
      let method = HTTPMethod.post
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      let jsonData: Data?
      
      init(marketId: Int, headers: [String: String], jsonData: Data?) {
         endPoint += "\(marketId)/add-to-cart/"
         self.headers = headers
         self.jsonData = jsonData
      }
   }
   
   struct GetCartItems: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      init(id: Int, headers: [String : String]) {
         endPoint += "\(id)/cart/"
         self.headers = headers
      }
   }
   
   struct DeleteCartItem: EndpointProtocol {
      //
      let method = HTTPMethod.delete

      var endPoint: String = urlBase + "/market/"

      var headers: [String: String]

      init(marketId: Int, itemId: Int, headers: [String: String]) {
         endPoint += "\(marketId)/cart/"
         endPoint += "\(itemId)/"
         self.headers = headers
      }
   }
   
   struct GetOrders: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      init(marketId: Int, headers: [String : String]) {
         endPoint += "\(marketId)/orders/"
         self.headers = headers
      }
   }
   
   struct PostOrders: EndpointProtocol {
      //
      let method = HTTPMethod.post
      
      var endPoint: String = urlBase + "/market/"
      
      var headers: [String : String]
      
      var body: [String : Any]
      
      init(marketId: Int, headers: [String: String], body: [String : Any]) {
         endPoint += "\(marketId)/orders/"
         self.headers = headers
         self.body = body
      }
   }
   
   struct GetStickerpacks: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String { urlBase + "/stickerpacks/"}
      
      var headers: [String : String]
   }
   
   struct GetStickers: EndpointProtocol {
      //
      let method = HTTPMethod.get
      
      var endPoint: String { urlBase + "/stickers/get/" }
      
      var headers: [String : String]
   }
   
   struct GetFile: EndpointProtocol {
      //
      var endPoint: String = urlBase
      
      var headers: [String: String]

      init(fileName: String, headers: [String: String]) {
         endPoint = endPoint + "/files/" + fileName
         self.headers = headers
      }
   }
   
   struct GetColleagues: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String { urlBase + "/colleagues/" }

      var headers: [String: String]

      let jsonData: Data?
   }
   
   struct GetDepartmentsTree: EndpointProtocol {
      let method = HTTPMethod.get
      
      var endPoint: String { urlBase + "/departments/tree/" }
      
      var headers: [String: String]
   }
   
   struct GetAvailableMarkets: EndpointProtocol {
      let method = HTTPMethod.get
      
      var endPoint: String { urlBase + "/markets/available/" }
      
      let headers: [String : String]
   }
   
   
   struct GetChallTemplateById: EndpointProtocol {
      var endPoint: String = urlBase + "/get-challenge-template/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         endPoint = endPoint + "&challenge_template=" + id + "/"
         self.headers = headers
      }
   }
   
   struct GetChallTemplateSections: EndpointProtocol {
      var endPoint: String = urlBase + "/get-challenge-template/"

      var headers: [String: String]

      init(id: String, headers: [String: String]) {
         //endPoint = endPoint + "/&challenge_template=" + id + "/"
         self.headers = headers
      }
   }
   
   struct CreateChallengeTemplate: EndpointProtocol {
      let method = HTTPMethod.post
      
      var endPoint: String = urlBase + "/create-challenge-template/"

      var headers: [String: String]

      var body: [String: Any]
   }

   struct UpdateChallengeTemplate: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String = urlBase + "/update-challenge-template/"

      var headers: [String: String]

      var body: [String : Any]
   }
   
   struct GetChallengeTemplates: EndpointProtocol {
      var endPoint: String = urlBase + "/get-challenges-templates/"

      var headers: [String: String]

      init(scope: String, offset: Int, limit: Int, headers: [String: String]) {
         endPoint = endPoint + "?scope=" + scope + "&offset=" + String(offset) + "&limit=" + String(limit)
         self.headers = headers
      }
   }
   
   struct Community: EndpointProtocol {
      let method = HTTPMethod.post
      
      var endPoint: String = urlBase + "/community/"
      
      let headers: [String : String]
      
      let body: [String : Any]
   }

   struct CreateCommunityWithParams: EndpointProtocol {
      let method = HTTPMethod.post

      var endPoint: String = urlBase + "/community/create/"

      let headers: [String : String]

      let body: [String : Any]
   }
   
   struct CreatePeriod: EndpointProtocol {
      let method = HTTPMethod.post
      
      var endPoint: String = urlBase + "/community/period/"
      
      let headers: [String : String]
      
      let body: [String : Any]
   }

   struct GetInviteLink: EndpointProtocol {
      let endPoint: String = urlBase + "/invitelink/"
      let headers: [String : String]
   }

   struct GetEventsByFilter: EndpointProtocol {
      var endPoint: String { urlBase + "/api/events/\(interpolated)" }

      let headers: [String: String]
      let interpolateFunction: (() -> String)?
   }
   
   struct CommunityInvite: EndpointProtocol {
      var endPoint: String = urlBase + "/community/invite/"
      
      let headers: [String : String]
      
      init(sharedKey: String,  headers: [String: String]) {
         endPoint = endPoint + "?invite=" + sharedKey
         self.headers = headers
      }
   }

   struct GetCategories: EndpointProtocol {
      var endPoint: String { urlBase + "/get-sections/" }
      let headers: [String: String]
      let body: [String : Any]
   }

   struct CreateCategory: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/create-challenge-template-section/" }
      let headers: [String: String]
      let jsonData: Data?
   }

   struct DeleteCategory: EndpointProtocol {
      let method = HTTPMethod.delete
      var endPoint: String { urlBase + "/template-section/\(interpolated)/" }
      let headers: [String: String]
      let interpolateFunction: (() -> String)?
   }
   
   struct DeleteChallenge: EndpointProtocol {
      let method = HTTPMethod.delete
      var endPoint: String { urlBase + "/api/challenges/\(interpolated)/" }
      let headers: [String : String]
      let interpolateFunction: (() -> String)?
   }
   
   struct UpdateChallenge: EndpointProtocol {
      let method = HTTPMethod.patch
      var endPoint: String { urlBase + "/api/challenges/\(interpolated)/" }
      var body: [String: Any]
      let headers: [String: String]
      let interpolateFunction: (() -> String)?
   }
   
   struct DeleteChallengeTemplate: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/delete-challenge-template/" }
      var body: [String : Any]
      let headers: [String : String]
   }

   struct VKAuth: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/api/auth/vkauth/" }
      let jsonData: Data?
      let headers: [String : String]
   }

   struct VKAuthChooseOrganization: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/api/auth/vkchooseorg/"}
      let jsonData: Data?
   }

   struct VKGetTokenByCode: EndpointProtocol {
      let method = HTTPMethod.get
      var endPoint: String {
         "https://oauth.vk.com/access_token?client_id=\(SecretConfig.vkAppId)&client_secret=\(SecretConfig.vkSecret)&redirect_uri=https://oauth.vk.com/blank.html&code=\(interpolated)"
      }
      let interpolateFunction: (() -> String)?
   }
   
   struct GetChallengeGroups: EndpointProtocol {
      var endPoint: String { urlBase + "/api/\(interpolated)" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
   }
   
   struct GetChallengeGroupById: EndpointProtocol {
      var endPoint: String { urlBase + "/api/\(interpolated)" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
   }
   
   struct GetChallengeChainParticipants: EndpointProtocol {
      var endPoint: String { urlBase + "/api/\(interpolated)/challenges/groups/\(interpolated2)/participants/" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
      let interpolateFunction2: (() -> String)?
   }
   
   struct GetTransactionsByGroup: EndpointProtocol {
      var endPoint: String { urlBase + "/user/transactions/group/\(interpolated)" }

      var headers: [String: String]
      
      let interpolateFunction: (() -> String)?
   }
   
   struct GetAuthMethod: EndpointProtocol {
      var endPoint: String { urlBase + "/api/auth/authmethod/" }
      var headers: [String: String]
   }
   
   struct GetAwards: EndpointProtocol {
      var endPoint: String { urlBase + "/api/\(interpolated)/awards/" }
      let headers: [String : String]

      let interpolateFunction: (() -> String)?
   }
   
   struct GetAwardGroups: EndpointProtocol {
      var endPoint: String { urlBase + "/api/\(interpolated)/awards/awardgroups/" }
      let headers: [String : String]

      let interpolateFunction: (() -> String)?
   }

   struct PostRequestAward: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/api/\(interpolated)/awards/" }
      let headers: [String : String]
      let body: [String : Any]

      let interpolateFunction: (() -> String)?
   }

   struct PostSetAwardToStatus: EndpointProtocol {
      let method = HTTPMethod.post
      var endPoint: String { urlBase + "/api/\(interpolated)/awards/status/" }
      let headers: [String : String]
      let body: [String : Any]

      let interpolateFunction: (() -> String)?
   }

   struct GetFlag: EndpointProtocol {
      var endPoint: String { urlBase + "/api/auth/flag/" }
      
      var headers: [String : String]
   }
   
   struct SetFlag: EndpointProtocol {
      var method = HTTPMethod.post
      var endPoint: String { urlBase + "/api/auth/flag/" }
      var body: [String : Any]
   }
   
   struct GetRecommendations: EndpointProtocol {
      var endPoint: String { urlBase + "/api/recommendations" }
      
      var headers: [String : String]
   }
}
