//
//  CategoriesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CategoriesScene<Asset: AssetProtocol>: BaseSceneExtended<Categories<Asset>> {

   // MARK: - View models

   private lazy var infoBlock = TitleBodyY()
      .setAll { title, body in
         title
            .set(Design.state.label.medium16)
            .text(Design.text.categories)
         body
            .set(Design.state.label.semibold14secondary)
            .text(Design.text.categoriesDescription)
      }
      .alignment(.center)
      .spacing(4)
      .padBottom(32)

   private lazy var cellPresenter = CreateCategoryCellPresenter<Design>()
   private lazy var tableModel = TableItemsModel()
      .presenters(cellPresenter.presenter)
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private lazy var editCategoriesButton = ButtonModel()
      .set(Design.state.button.brandTransparent)
      .title(Design.text.categoriesEdit)

   private lazy var saveButton = ButtonModel()
      .set(Design.state.button.default)
      .title(Design.text.save)

   // MARK: - System view models

   private lazy var activityModel = Design.model.common.activityIndicatorSpaced
   private lazy var hereIsEmptyModel = Design.model.common.hereIsEmptySpaced
   private lazy var errorModel = Design.model.common.systemErrorBlock

   // MARK: - Start

   override func start() {
      super.start()

      initScenario(.init(
         payload: on(\.input),
         didTapEditCategories: editCategoriesButton.on(\.didTap),
         didSelectCategory: cellPresenter.on(\.didCheckmarked),
         didTapSaveButton: saveButton.on(\.didTap)
      ))
      
      mainVM.backColor(Design.color.background)

      mainVM.closeButton.on(\.didTap, self) {
         $0.dismiss()
      }

      mainVM.bodyStack
         .arrangedModels(
            infoBlock,
            activityModel,
            hereIsEmptyModel.hidden(true),
            errorModel.hidden(true),
            tableModel,
            Spacer()
         )

      mainVM.footerStack
         .spacing(8)
         .arrangedModels(
            editCategoriesButton,
            saveButton
         )

      scenario.configureAndStart()
   }
}

extension CategoriesScene: StateMachine {
   func setState(_ state: ModelState) {
      switch state {
      case let .present(categories):
         guard categories.isNotEmpty else {
            setState(.hereIsEmpty)
            return
         }
         activityModel.hidden(true)
         hereIsEmptyModel.hidden(true)
         errorModel.hidden(true)
         tableModel.hidden(false)

         tableModel.items(categories)

      case .loading:
         activityModel.hidden(false)
         hereIsEmptyModel.hidden(true)
         errorModel.hidden(true)
         tableModel.hidden(true)
      case .error:
         activityModel.hidden(true)
         hereIsEmptyModel.hidden(true)
         errorModel.hidden(false)
         tableModel.hidden(true)
      case .hereIsEmpty:
         activityModel.hidden(true)
         hereIsEmptyModel.hidden(false)
         errorModel.hidden(true)
         tableModel.hidden(true)
      case .routeToEditCategories(let scope):
         Asset.router?.route(
            .presentModallyOnPresented(.automatic),
            scene: \.categoriesEdit,
            payload: .topLevel(currentScope: scope),
            finishWork: scenario.events.editCategoriesFinishWork
         )
      case let .finishWithSelected(selected):
         finishSucces(selected)
         dismiss()
      }
   }
}
