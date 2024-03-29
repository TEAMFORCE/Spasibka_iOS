//
//  ChallengeTemplatesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

struct ChallengeTemplatesSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class ChallengeTemplatesScene<Asset: ASP>: BaseParamsScene<ChallengeTemplatesSceneParams<Asset>> {
   private lazy var challengeTemplatesSceneViewModel = ChallengeTemplatesSceneViewModel<Asset>()
   
   override func start() {
      mainVM.bodyStack
         .arrangedModels(challengeTemplatesSceneViewModel)

      challengeTemplatesSceneViewModel.scenarioStart()
   }

}

// MARK: - View Model

final class ChallengeTemplatesSceneViewModel<Asset: ASP>: VStackModel, Assetable, Scenarible, Eventable {
   typealias Events = MainSubsceneEvents
   var events: EventsStore = .init()

   private(set) lazy var scenario = ChallengeTemplatesScenario<Asset>(
      works: ChallengeTemplatesWorks(),
      stateDelegate: stateDelegate,
      events: .init(
         presentMyTemplates: filterButtons.on(\.didTapFilterMy),
         presentOursTemplates: filterButtons.on(\.didTapFilterOurs),
         presentCommonTemplates: filterButtons.on(\.didTapFilterCommon),
         requestPagination: templatesTable.on(\.requestPagination),
         didChangeSearchText: searchField.on(\.didEditingChanged),
         didSelectTemplateAtIndex: templatesTable.on(\.didSelectItemAtIndex),
         didTapEditTemplateAtIndex: eventableCellPresenter.on(\.didTapEditTemplateAtIndex),
         didTapCreateButton: createTemplateButton.on(\.didTap),
         reloadTemplates: .init()
      )
   )

   private lazy var searchField = Design.model.transact.userSearchTextField
      .placeholder(Design.text.searchByTemplates)
   private lazy var searchFieldContainer = searchField
      .wrappedX()
      .padding(.horizontalOffset(16))
      .padBottom(16)

   private lazy var filterButtons = TemplatesFilterButtons<Design>()
  
   private lazy var eventableCellPresenter = TemplateCellEventablePresenter<Design>()

   private lazy var templatesTable = TableItemsModel()
      .presenters(
         SpacerPresenter.presenter,
         eventableCellPresenter.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private lazy var createTemplateButton = ButtonModel()
      .set(Design.state.button.default)
      .size(.square(38))
      .cornerRadius(38 / 2)
      .backColor(Design.color.backgroundBrand)
      .image(Design.icon.tablerPlus, color: Design.color.iconInvert)

   private lazy var activityBlock = Design.model.common.activityIndicatorSpaced
      .hidden(true)
   private lazy var errorBlock = Design.model.common.connectionErrorBlock
      .hidden(true)
   private lazy var hereIsEmprtyBlock = Design.model.common.hereIsEmptySpaced
      .hidden(true)

   override func start() {
      super.start()

      backColor(Design.color.background)
      
      arrangedModels(
         searchFieldContainer,
         Wrapped2X(filterButtons, createTemplateButton)
            .spacing(16)
            .padHorizontal(16)
            .padBottom(16),
         activityBlock,
         errorBlock,
         hereIsEmprtyBlock,
         templatesTable
      )

      templatesTable
         .on(\.didScroll) { [weak self] in
            self?.send(\.didScroll, $0.velocity)
         }
         .on(\.willEndDragging) { [weak self] in
            if $0.velocity > 0 {
               self?.searchFieldContainer.hidden(true, isAnimated: true)
//               self?.filterButtons.hidden(true, isAnimated: true)
//               self?.createTemplateButton.hidden(true, isAnimated: true)
            } else if $0.velocity < 0 {
               self?.searchFieldContainer.hidden(false, isAnimated: true)
//               self?.filterButtons.hidden(false, isAnimated: true)
//               self?.createTemplateButton.hidden(false, isAnimated: true)
            }
            self?.send(\.willEndDragging, $0.velocity)
         }
         .on(\.refresh, self) {
            $0.scenario.events.reloadTemplates.sendAsyncEvent()
         }

      setState(.initial)
   }
}

enum ChallengeTemplatesState {
   case initial
   case presentObjects([ChallengeTemplate])
   case loadingError
   case presentCreateChallengeWithTemplate(ChallengeTemplate)
   case presentCreateChallengeTemplate(ChallengeTemplatesScope)
   case presentUpdateTemplateWithTemplate(ChallengeTemplate, scope: ChallengeTemplatesScope)
}

extension ChallengeTemplatesSceneViewModel: StateMachine {
   func setState(_ state: ChallengeTemplatesState) {
      switch state {
      case .initial:
         activityBlock.hidden(false)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         templatesTable.hidden(true)
      case let .presentObjects(templates):
         activityBlock.hidden(true)
         errorBlock.hidden(true)

         guard templates.isEmpty == false else {
            templatesTable.hidden(true)
            hereIsEmprtyBlock.hidden(false)
            return
         }

         templatesTable.hidden(false)
         hereIsEmprtyBlock.hidden(true)
         templatesTable.items(templates + [SpacerItem(160)])
      case .loadingError:
         templatesTable.hidden(true)
         activityBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         errorBlock.hidden(false)
      case let .presentCreateChallengeWithTemplate(template):
         Asset.router?.route(
            .presentModally(.pageSheet),
            scene: \.challengeCreate,
            payload: .createChallengeWithTemplate(template),
            finishWork: .init()
         )
      case let .presentUpdateTemplateWithTemplate(template, scope):
         Asset.router?.route(
            .presentModally(.pageSheet),
            scene: \.createChallengeTemplate,
            payload: .updateTemplateWithTemplate(template, scope: scope),
            finishWork: scenario.events.reloadTemplates
         )
      case let .presentCreateChallengeTemplate(scope):
         Asset.router?.route(
            .presentModally(.pageSheet),
            scene: \.createChallengeTemplate,
            payload: .createTemplate(scope: scope),
            finishWork: scenario.events.reloadTemplates
         )
      }
   }
}
