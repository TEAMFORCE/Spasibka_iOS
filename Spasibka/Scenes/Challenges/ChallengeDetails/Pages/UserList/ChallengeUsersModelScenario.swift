//
//  ChallengeUsersModelScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2024.
//

import StackNinja

struct ChallengeUsersModelScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()
}

final class ChallengeUsersModelScenario<Asset: ASP>: BasePayloadedScenario<
ChallengeUsersModelScenarioEvents, ChallengeUsersModelState, ChallengeCandidatesWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadChallengeContenders)
         .doMap {
            $0.map { contender in
               let photo = SpasibkaEndpoints.tryConvertToImageUrl(contender.participantPhoto)
               return UserViewModelState(
                  imageUrl: photo, name: contender.participantName, surname: contender.participantSurname, caption: nil
               )
            }
         }
         .onSuccess(setState) { .presentUsers($0) }
         .onFail(setState, .error)
   }
}
