//
//  ChallengeTemplatesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.05.2023.
//

import StackNinja
import UIKit

//final class ChallengeTemplatesSceneOld<Asset: ASP>: BaseSceneExtended<ChallengeTemplates<Asset>> {
//   private lazy var searchField = Design.model.transact.userSearchTextField
//      .placeholder(Design.text.searchByTemplates)
//
//   private lazy var filterButtons = TemplatesFilterButtons<Design>()
//
//   private lazy var eventableCellPresenter = TemplateCellEventablePresenter<Design>()
//
//   private lazy var templatesTable = TableItemsModel()
//      .presenters(
//         SpacerPresenter.presenter,
//         eventableCellPresenter.presenter
//      )
//      .backColor(Design.color.background)
//      .setNeedsLayoutWhenContentChanged()
//
//   private lazy var createTemplateButton = ButtonModel()
//      .set(Design.state.button.default)
//      .title(Design.text.newTemplate)
//
//   private lazy var activityBlock = Design.model.common.activityIndicatorSpaced
//      .hidden(true)
//   private lazy var errorBlock = Design.model.common.connectionErrorBlock
//      .hidden(true)
//   private lazy var hereIsEmprtyBlock = Design.model.common.hereIsEmptySpaced
//      .hidden(true)
//
//   override func start() {
//      super.start()
//
//      initScenario(.init(
//         input: on(\.input),
//         presentMyTemplates: filterButtons.on(\.didTapFilterMy),
//         presentOursTemplates: filterButtons.on(\.didTapFilterOurs),
//         presentCommonTemplates: filterButtons.on(\.didTapFilterCommon),
//         requestPagination: templatesTable.on(\.requestPagination),
//         didChangeSearchText: searchField.on(\.didEditingChanged),
//         didSelectTemplateAtIndex: templatesTable.on(\.didSelectItemAtIndex),
//         didTapEditTemplateAtIndex: eventableCellPresenter.on(\.didTapEditTemplateAtIndex),
//         didTapCreateButton: createTemplateButton.on(\.didTap),
//         reloadTemplates: .init()
//      ))
//
//      vcModel?.title(Design.text.сhallengeTemplates)
//
//      mainVM.backColor(Design.color.background)
//
//      mainVM.bodyStack
//         .arrangedModels(
//            searchField,
//            Spacer(16),
//            filterButtons,
//            Spacer(8),
//            activityBlock,
//            errorBlock,
//            hereIsEmprtyBlock,
//            templatesTable
//         )
//         .padBottom(-40)
//
//      mainVM.addModel(createTemplateButton) {
//         $0.fitToBottom($1, offset: 32, sideOffset: 16)
//      }
//
//      setState(.initial)
//      scenario.configureAndStart()
//   }
//}
//
//extension ChallengeTemplatesSceneOld: StateMachine {
//   func setState(_ state: ModelState) {
//      switch state {
//      case .initial:
//         activityBlock.hidden(false)
//         errorBlock.hidden(true)
//         hereIsEmprtyBlock.hidden(true)
//         templatesTable.hidden(true)
//      case let .presentObjects(templates):
//         activityBlock.hidden(true)
//         errorBlock.hidden(true)
//
//         guard templates.isEmpty == false else {
//            templatesTable.hidden(true)
//            hereIsEmprtyBlock.hidden(false)
//            return
//         }
//
//         templatesTable.hidden(false)
//         hereIsEmprtyBlock.hidden(true)
//         templatesTable.items(templates + [SpacerItem(160)])
//      case .loadingError:
//         templatesTable.hidden(true)
//         activityBlock.hidden(true)
//         hereIsEmprtyBlock.hidden(true)
//         errorBlock.hidden(false)
//      case let .presentCreateChallengeWithTemplate(template):
//         Asset.router?.route(
//            .presentModally(.pageSheet),
//            scene: \.challengeCreate,
//            payload: .createChallengeWithTemplate(template),
//            finishWork: .init()
//         )
//      case let .presentUpdateTemplateWithTemplate(template, scope):
//         Asset.router?.route(
//            .presentModally(.pageSheet),
//            scene: \.createChallengeTemplate,
//            payload: .updateTemplateWithTemplate(template, scope: scope),
//            finishWork: scenario.events.reloadTemplates
//         )
//      case let .presentCreateChallengeTemplate(scope):
//         Asset.router?.route(
//            .presentModally(.pageSheet),
//            scene: \.createChallengeTemplate,
//            payload: .createTemplate(scope: scope),
//            finishWork: scenario.events.reloadTemplates
//         )
//      }
//   }
//}
