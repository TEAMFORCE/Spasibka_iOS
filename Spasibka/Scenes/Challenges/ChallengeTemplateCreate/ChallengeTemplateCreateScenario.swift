//
//  ChallengeTemplateCreateScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.07.2023.
//

import StackNinja

final class ChallengeTemplateCreateScenario<Asset: ASP>: BaseScenarioExtended<ChallengeTemplateCreate<Asset>> {
   override func configure() {
      super.configure()

      events.payload
         .doSaveResult()
         .doVoidNext(works.createChallengeGet)
         .onFail(setState, .errorState)
         .doLoadResult()
         .doNext(works.saveTemplateValues)
         .onSuccess { [weak self] (result: ChallengeTemplateCreateInput) in
            guard let stateFunc = self?.setState else { return }
            switch result {
            case .createTemplate:
               stateFunc(.initCreateTemplate)
            case let .updateTemplateWithTemplate(value, _):
               stateFunc(.initUpdateTemplateWithTemplate(value))
            }
         }
         .doVoidNext(works.tryLoadPhoto)
         .onSuccess(setState) { .presentLoadedPhoto($0) }
         .onSuccess(setState, .readyToInput)
         .doVoidNext(works.getSelectedCategories)
         .onSuccess(setState) { .presentCategoriesTags($0) }
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didTitleInputChanged
         .doNext(works.titleCacher)
         .doNext(works.setTitle)
         .onSuccess(setState) { .updateTitleTextField($0) }
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didDescriptionInputChanged
         .doNext(works.descriptCacher)
         .doNext(works.setDesription)
         .onSuccess(setState) { .updateDescriptTextField($0) }
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didSendPressed
         .onSuccess(setState, .awaitingState)
         .doNext(works.createOrUpdateTemplate)
         .onSuccess(setState, .challengeCreated)
         .onFail(setState, .errorState)

      events.didSettingsPressed
         .doNext(works.getSavedSettings)
         .onSuccess(setState) { .routeToSettingsScene($0) }

      events.didCategoriesPressed
         .doNext(works.getCategoriesInput)
         .onSuccess(setState) { .routeToCategories($0) }

      events.didSelectCategories
         .doNext(works.setSelectedCategories)
         .doNext(works.getSelectedCategories)
         .onSuccess(setState) { .presentCategoriesTags($0) }
      
      events.didTapDelete
         .doNext(works.deleteChallengeTemplate)
         .onSuccess(setState) { .challengeDeleted }
         .onFail {
            print("fail")
         }
   }
}
