//
//  GetChallengesUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.10.2022.
//

import StackNinja
import UIKit

enum ChallengeCondition: String, Codable {
   case W
   case A // active
   case F
   case C // closed
   case D // deffered
}

enum ChallengeState: String, Codable {
   case O = "От имени организации"
   case U = "От имени пользователя"
   case P = "Является публичным"
   case C = "Является командным"
   case R = "Нужна регистрация"
   case G = "Нужна картинка"
   case M = "Запрет комментариев"
   case E = "Разрешить комментарии только для участников"
   case L = "Лайки запрещены"
   case T = "Разрешить лайки только для участников"
   case X = "Комментарии отчетов разрешены только автору отчета, организатору и судьям"
   case W = "Комментарии отчетов разрешены только участникам"
   case I = "Лайки отчетов разрешены только участникам"
   case N = "Участник может использовать никнейм"
   case H = "Участник может сделать отчёт приватным"
   case A = "Отчеты анонимизированы до подведения итогов, не видны ни имена пользователей, ни псевдонимы"
   case Q = "Участник может рассылать приглашения"
   case Y = "Подтверждение будет выполняться судейской коллегией (через выдачу ими баллов)"
   case D = "Отложен"
}

enum ChallengeStatus: String, Codable {
   case owner = "Вы создатель челленджа"
   case canSendReport = "Можно отправить отчёт"
   case reportSent = "Отчёт отправлен"
   case reportAccepted = "Отчёт подтверждён"
   case reportDeclined = "Отчёт отклонён"
   case rewarded = "Получено вознаграждение"
}

struct ChallengeResponse: Decodable {
   let data: [Challenge]
}

final class Challenge: Codable {
   internal init(
      id: Int,
      userLiked: Bool? = nil,
      likesAmount: Int? = nil,
      name: String? = nil,
      photo: String? = nil,
      updatedAt: String? = nil,
      states: [ChallengeState]? = nil,
      description: String? = nil,
      startBalance: Int? = nil,
      creatorId: Int,
      parameters: [Challenge.Parameter]? = nil,
      endAt: String? = nil,
      approvedReportsAmount: Int,
      status: String? = nil,
      isNewReports: Bool,
      winnersCount: Int? = nil,
      creatorOrganizationId: Int? = nil,
      prizeSize: Int,
      awardees: Int,
      fund: Int,
      creatorName: String? = nil,
      creatorSurname: String? = nil,
      creatorPhoto: String? = nil,
      creatorTgName: String? = nil,
      creatorNickname: String? = nil,
      active: Bool? = nil,
      completed: Bool? = nil,
      remainingTopPlaces: Int? = nil,
      photoCache: UIImage? = nil,
      algorithmName: String? = nil,
      algorithmType: Int? = nil,
      showContenders: Bool? = nil,
      severalReports: Bool? = nil,
      fromOrganization: Bool? = nil,
      challengeCondition: ChallengeCondition? = nil,
      organizationName: String? = nil,
      photos: [String]? = nil,
      participantsTotal: Int? = nil,
      startAt: String? = nil,
      linkToShare: String? = nil,
      step: Int? = nil,
      isAvailable: Bool? = nil
   ) {
      self.id = id
      self.userLiked = userLiked
      self.likesAmount = likesAmount
      self.name = name
      self.photo = photo
      self.updatedAt = updatedAt
      self.states = states
      self.description = description
      self.startBalance = startBalance
      self.creatorId = creatorId
      self.parameters = parameters
      self.endAt = endAt
      self.approvedReportsAmount = approvedReportsAmount
      self.status = status
      self.isNewReports = isNewReports
      self.winnersCount = winnersCount
      self.creatorOrganizationId = creatorOrganizationId
      self.prizeSize = prizeSize
      self.awardees = awardees
      self.fund = fund
      self.creatorName = creatorName
      self.creatorSurname = creatorSurname
      self.creatorPhoto = creatorPhoto
      self.creatorTgName = creatorTgName
      self.creatorNickname = creatorNickname
      self.active = active
      self.completed = completed
      self.remainingTopPlaces = remainingTopPlaces
      self.photoCache = photoCache
      self.algorithmName = algorithmName
      self.algorithmType = algorithmType
      self.showContenders = showContenders
      self.severalReports = severalReports
      self.fromOrganization = fromOrganization
      self.challengeCondition = challengeCondition
      self.organizationName = organizationName
      self.photos = photos
      self.participantsTotal = participantsTotal
      self.startAt = startAt
      self.linkToShare = linkToShare
      self.step = step
      self.isAvailable = isAvailable
   }

   let id: Int
   let userLiked: Bool?
   let likesAmount: Int?
   let name: String?
   let photo: String?
   let updatedAt: String?
   let states: [ChallengeState]?
   let description: String?
   let startBalance: Int?
   let creatorId: Int
   let parameters: [Parameter]?
   let startAt: String?
   let endAt: String?
   let approvedReportsAmount: Int
   let status: String?
   let isNewReports: Bool
   let winnersCount: Int?
   let creatorOrganizationId: Int?
   let prizeSize: Int
   let awardees: Int
   let fund: Int
   let creatorName: String?
   let creatorSurname: String?
   let creatorPhoto: String?
   let creatorTgName: String?
   let creatorNickname: String?
   let active: Bool?
   let completed: Bool?
   let remainingTopPlaces: Int?
   let algorithmName: String?
   let algorithmType: Int?
   let showContenders: Bool?
   let severalReports: Bool?
   let fromOrganization: Bool?
   let challengeCondition: ChallengeCondition?
   let organizationName: String?
   let photos: [String]?
   let participantsTotal: Int?
   let linkToShare: String?
   let step: Int?
   let isAvailable: Bool?

   struct Parameter: Codable {
      let id: Int
      let value: Int?
      let isCalc: Bool?

      enum CodingKeys: String, CodingKey {
         case id
         case value
         case isCalc = "is_calc"
      }
   }

   enum CodingKeys: String, CodingKey {
      case id, name, photo, step
      case likesAmount = "likes_amount"
      case userLiked = "user_liked"
      case updatedAt = "updated_at"
      case states
      case description
      case startBalance = "start_balance"
      case creatorId = "creator_id"
      case parameters
      case startAt = "start_at"
      case endAt = "end_at"
      case approvedReportsAmount = "approved_reports_amount"
      case status
      case isNewReports = "is_new_reports"
      case winnersCount = "winners_count"
      case creatorOrganizationId = "creator_organization_id"
      case prizeSize = "prize_size"
      case awardees, fund
      case creatorName = "creator_name"
      case creatorSurname = "creator_surname"
      case creatorPhoto = "creator_photo"
      case creatorTgName = "creator_tg_name"
      case creatorNickname = "creator_nickname"
      case active, completed
      case remainingTopPlaces = "remaining_top_places"
      case algorithmName = "algorithm_name"
      case algorithmType = "algorithm_type"
      case showContenders = "show_contenders"
      case severalReports = "multiple_reports"
      case fromOrganization = "from_organization"
      case challengeCondition = "challenge_condition"
      case organizationName = "organization_name"
      case photos
      case participantsTotal = "participants_total"
      case linkToShare = "link_to_share"
      case isAvailable = "is_available"
   }

   // not codable extensions
   var photoCache: UIImage?
}

struct ChallengesRequest {
   //   let token: String
   let activeOnly: Bool?
   let deferredOnly: Bool?
   //   let pagination: Pagination?
   let groupID: Int?
}

extension Challenge {
   /// makes mock challenge with random fields
   static func makeMock() -> Challenge {
      Challenge(
         id: 1,
         userLiked: true,
         likesAmount: 10,
         name: "Challenge name",
         photo: "https://picsum.photos/200/300",
         updatedAt: "2021-01-01T00:00:00.000Z",
         states: [],
         description: "Challenge description",
         startBalance: 100,
         creatorId: 1,
         parameters: [],
         endAt: "2021-01-01T00:00:00.000Z",
         approvedReportsAmount: 10,
         status: "active",
         isNewReports: true,
         winnersCount: 10,
         creatorOrganizationId: 1,
         prizeSize: 100,
         awardees: 10,
         fund: 100,
         creatorName: "Creator name",
         creatorSurname: "Creator surname",
         creatorPhoto: "https://picsum.photos/200/300",
         creatorTgName: "Creator tg name",
         active: true,
         completed: true,
         remainingTopPlaces: 10,
         photoCache: nil,
         algorithmName: "algorithm name",
         algorithmType: 1,
         showContenders: true,
         severalReports: true,
         fromOrganization: true,
         challengeCondition: ChallengeCondition.A,
         organizationName: "Organization name",
         photos: [],
         participantsTotal: 10,
         startAt: "2021-01-01T00:00:00.000Z",
         linkToShare: "https://picsum.photos/200/300",
         isAvailable: true
      )
   }

   static func makeRandomMock() -> Challenge {
      Challenge(
         id: Int.random(in: 1 ... 100),
         userLiked: Bool.random(),
         likesAmount: Int.random(in: 1 ... 100),
         name: String.random(20),
         photo: "https://picsum.photos/200/300",
         updatedAt: "2021-01-01T00:00:00.000Z",
         states: [],
         description: String.random(20),
         startBalance: Int.random(in: 1 ... 100),
         creatorId: Int.random(in: 1 ... 100),
         parameters: [],
         endAt: "2021-01-01T00:00:00.000Z",
         approvedReportsAmount: Int.random(in: 1 ... 100),
         status: "active",
         isNewReports: Bool.random(),
         winnersCount: Int.random(in: 1 ... 100),
         creatorOrganizationId: Int.random(in: 1 ... 100),
         prizeSize: Int.random(in: 1 ... 100),
         awardees: Int.random(in: 1 ... 100),
         fund: Int.random(in: 1 ... 100),
         creatorName: String.random(20),
         creatorSurname: String.random(20),
         creatorPhoto: "https://picsum.photos/200/300",
         creatorTgName: String.random(20),
         active: Bool.random(),
         completed: Bool.random(),
         remainingTopPlaces: Int.random(in: 1 ... 100),
         photoCache: nil,
         algorithmName: "algorithm name",
         algorithmType: Int.random(in: 1 ... 100),
         showContenders: Bool.random(),
         severalReports: Bool.random(),
         fromOrganization: Bool.random(),
         challengeCondition: ChallengeCondition.A,
         organizationName: String.random(20),
         photos: [],
         participantsTotal: Int.random(in: 1 ... 100),
         startAt: "2021-01-01T00:00:00.000Z",
         linkToShare: "https://picsum.photos/200/300",
         step: Int.random(in: 0...5),
         isAvailable: true
      )
   }
}

struct GetChallengesUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<ChallengesRequest>, [Challenge]> { .init { work in
      let input = work.in
      let request = input.request
      let groupIdString = request.groupID != nil ? "&group_id=\(request.groupID.unwrap)" : ""

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetChallenges(
               headers: makeCookiedTokenHeader(token))
            {
               "?limit=\(input.limit)&offset=\(input.offset)"
                  + "&active_only=" + String(request.activeOnly ?? false)
                  + "&show_deferred=" + String(request.deferredOnly ?? false)
                  + groupIdString
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = ChallengeResponse(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: response.data)
               }
               .onFail {
                  work.fail()
               }
         }
   } }
}
