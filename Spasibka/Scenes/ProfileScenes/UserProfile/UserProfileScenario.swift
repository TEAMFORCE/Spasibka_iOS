//
//  UserProfileScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.12.2022.
//

import StackNinja

struct UserProfileScenarioInput: ScenarioEvents {   
   let loadProfileById: Out<ProfileID>
   let thankButtonTapped: Out<Void>
}

struct UserProfileScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = UserProfileScenarioInput
   typealias ScenarioModelState = UserProfileSceneState
   typealias ScenarioWorks = UserProfileWorks<Asset>
}

final class UserProfileScenario<Asset: ASP>: BaseParamsScenario<UserProfileScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      events.loadProfileById
         .doNext(works.loadProfileById)
         .onSuccess(setState, .loaded)
         .onFail(setState, .loadError)
         //
         .doVoidNext(works.getUserAvatarUrl)
         .onSuccess(setState) { .userAvatar($0) }
         .doAnyway(works.getUserSurname)
         .doSaveResult()
         .doAnyway(works.getUserName)
         .onSuccessMixSaved(setState) { .userName(.init(text1: $0 + " ", text2: $1, text3: "")) }
         .doAnyway(works.getUserStatus)
         .onSuccess(setState) { .userStatus($0) }
         .doAnyway(works.getUserSecondaryStatus)
         .onSuccess(setState) { .userSecondaryStatus($0) }
//         .doAnyway(works.loadTagPercents)
//         .doAnyway(works.getTagsPercentsData)
//         .onSuccess(setState) { .tagsPercents($0) }
         .doAnyway(works.getUserContacts)
         .onSuccess(setState) { .userContacts($0) }
         .doAnyway(works.getUserWorkData)
         .onSuccess(setState) { .userWorkPlace($0) }
         .doAnyway(works.getUserRoleData)
         .onSuccess(setState) { .userRole($0) }
      
      events.thankButtonTapped
         .doNext(works.getUserId)
         .onSuccess(setState) { .presentTransactScene($0) }
   }
}
