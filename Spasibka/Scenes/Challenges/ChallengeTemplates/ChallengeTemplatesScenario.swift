//
//  ChallengeTemplatesScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.05.2023.
//

import StackNinja

struct ChallengeTemplatesEvents: ScenarioEvents {
   let presentMyTemplates: Out<Void>
   let presentOursTemplates: Out<Void>
   let presentCommonTemplates: Out<Void>

   let requestPagination: VoidWork

   let didChangeSearchText: Out<String>
   let didSelectTemplateAtIndex: Out<Int>
   let didTapEditTemplateAtIndex: Out<Int>

   let didTapCreateButton: Out<Void>

   let reloadTemplates: VoidWork
}

final class ChallengeTemplatesScenario<Asset: ASP>: BaseWorkableScenario<
   ChallengeTemplatesEvents,
   ChallengeTemplatesState,
   ChallengeTemplatesWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doSendEvent(events.presentMyTemplates)

      events.presentMyTemplates
         .onSuccess(setState, .initial)
         .doNext(works.setCurrentFilterMy)
         .doSendEvent(events.requestPagination)

      events.presentOursTemplates
         .onSuccess(setState, .initial)
         .doNext(works.setCurrentFilterOurs)
         .doSendEvent(events.requestPagination)

      events.presentCommonTemplates
         .onSuccess(setState, .initial)
         .doNext(works.setCurrentFilterCommon)
         .doSendEvent(events.requestPagination)

      events.requestPagination
         .doNext(works.loadTemplatesForCurrentFilter)
         .onFail(setState, .loadingError)
         .doNext(works.getTemplatesForCurrentFilter)
         .onSuccess(setState) { .presentObjects($0) }

      events.didChangeSearchText
         .doNext(works.getFilteredTemplatesForCurrentFilter)
         .onSuccess(setState) { .presentObjects($0) }

      events.didSelectTemplateAtIndex
         .doNext(works.getTemplateByIndex)
         .onSuccess(setState) { template, _ in .presentCreateChallengeWithTemplate(template) }

      events.didTapEditTemplateAtIndex
         .doNext(works.getTemplateByIndex)
         .onSuccess(setState) { .presentUpdateTemplateWithTemplate($0, scope: $1) }

      events.didTapCreateButton
         .doNext(works.getCurrentScope)
         .onSuccess(setState) { .presentCreateChallengeTemplate($0) }

      events.reloadTemplates
         .doNext(works.resetTemplates)
         .onSuccess(setState, .initial)
         .doSendEvent(events.requestPagination)
   }
}
