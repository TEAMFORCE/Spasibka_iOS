//
//  NotificationToChallengeDetailsSceneInput.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.11.2022.
//

struct NotificationToChallengeDetailsData: Converter {
   static func convert(_ input: Notification) -> Challenge? {
      let notify = input
      guard
         let challData = input.challengeData
      else { return nil }

      let chall = Challenge(
         id: challData.challengeId,
         userLiked: nil,
         likesAmount: nil,
         name: challData.challengeName,
         photo: nil,
         updatedAt: notify.updatedAt,
         states: nil,
         description: nil,
         startBalance: nil,
         creatorId: 0,
         parameters: nil,
         endAt: nil,
         approvedReportsAmount: 0,
         status: nil,
         isNewReports: false,
         winnersCount: nil,
         creatorOrganizationId: nil,
         prizeSize: 0,
         awardees: 0,
         fund: 0,
         creatorName: challData.creatorFirstName,
         creatorSurname: challData.creatorSurname,
         creatorPhoto: challData.creatorPhoto,
         creatorTgName: challData.creatorTgName,
         active: nil,
         completed: nil,
         remainingTopPlaces: nil,
         photoCache: nil,
         challengeCondition: nil
      )

      return chall
   }
}
