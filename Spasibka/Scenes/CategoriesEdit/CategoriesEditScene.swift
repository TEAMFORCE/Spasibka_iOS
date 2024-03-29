//
//  CategoriesEditScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja
import UIKit

final class CategoriesEditVM<Design: DSP>: VStackModel {
   let parentCategory: CategoryData?
   required init(parentCategory: CategoryData?) {
      self.parentCategory = parentCategory
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   private(set) lazy var cellPresenter = EditCategoryCellPresenter<Design>()
   private(set) lazy var tableModel = TableItemsModel()
      .presenters(cellPresenter.presenter)
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private(set) lazy var hereIsEmptyModel = Design.model.common.hereIsEmptySpaced

   override func start() {
      super.start()
      tableModel.cancelToucherForAllGestures(false)
      arrangedModels(
         hereIsEmptyModel.hidden(true),
         tableModel
      )
   }
}

final class CategoriesEditScene<Asset: AssetProtocol>: BaseSceneExtended<CategoriesEdit<Asset>> {
   // MARK: - View models

   private lazy var backButton = ButtonModel()
      .backImage(Design.icon.tablerArrowLeft.withTintColor(Design.color.iconBrand))
      .size(.square(24))
      .hidden(true)
      .on(\.didTap, self) {
         $0.pagesModel.pop()
      }

   private(set) lazy var infoBlock = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.categoriesEdit)

   private var pages = [CategoriesEditVM<Design>]()
   private lazy var pagesModel = PagingScrollViewModel()
      .bounce(false)
      .on(\.didPop, self) {
         $0.setState(.popCategories($1))
      }
      .on(\.didViewModelPresented) { [weak self] in
         let category = ($0 as? CategoriesEditVM<Design>)?.parentCategory
         let name = category?.name
         self?.createCategoryPopup.setState(.setParentCategory(category))
         self?.infoBlock.text(name ?? Design.text.categoriesEdit)
      }

   private(set) lazy var filterButtons = TemplatesFilterButtons<Design>()
      .padHorizontal(16)
      .hidden(true)

   private lazy var addCategoryButton = ButtonModel()
      .set(Design.state.button.brandOutline)
      .image(Design.icon.tablerCirclePlus, color: Design.color.iconBrand)
      .imageInset(.right(8))
      .title(Design.text.addButton)

   private lazy var saveButton = ButtonModel()
      .set(Design.state.button.default)
      .title(Design.text.close)
      .on(\.didTap, self) {
         $0.finishSucces()
         $0.dismiss()
      }

   // MARK: - System models

   private(set) lazy var activityModel = Design.model.common.activityIndicatorSpaced
   private(set) lazy var errorModel = Design.model.common.connectionErrorBlock

   // MARK: - Bottom popups

   private lazy var bottomPopupPresenter = BottomPopupPresenter()
   private lazy var createCategoryPopup = CreateCategoryPopup<Asset>()
      .maxHeight(UIScreen.main.bounds.height * 0.66)

   private lazy var alertPresenter = CenterPopupPresenter()

   // MARK: - Start

   override func start() {
      super.start()

      initScenario(.init(
         payload: on(\.input),
         didSelectScopeButton: filterButtons.on(\.didSelectButton),
         didSelectCategory: .init(), // tableModel.on(\.didSelectItemAtIndex),
         didTapDeleteCatetegory: .init(), // cellPresenter.on(\.didTapDeleteButtonAtIndex),
         didTapCreateCategory: addCategoryButton.on(\.didTap),
         didFinishCreateNewCategory: createCategoryPopup.finishWork
      ))
      
      mainVM.backColor(Design.color.background)

      mainVM.closeButton.on(\.didTap, self) {
         $0.finishSucces()
         $0.dismiss()
      }

      mainVM.bodyStack
         .arrangedModels(
            infoBlock
               .centeredX()
               .padBottom(32),
            filterButtons,
            Spacer(8),
            pagesModel,
            activityModel,
            errorModel.hidden(true),
            Spacer()
         )
         .padding(.horizontalOffset(-16))

      mainVM.footerStack
         .spacing(8)
         .arrangedModels(
            addCategoryButton,
            saveButton
         )

      mainVM.titlePanel.insertArrangedModel(backButton, at: 0)

      createCategoryPopup.closeButton.on(\.didTap, self) {
         $0.setState(.hideBottomPopup)
      }

      scenario.configureAndStart()
   }
}

extension CategoriesEditScene {
   var currentPage: CategoriesEditVM<Design> {
      guard let page = pages.last else { return CategoriesEditVM<Design>(parentCategory: nil) }

      return page
   }
}

extension CategoriesEditScene: StateMachine {
   private func setFirstPageState(_ isFirst: Bool) {
      if isFirst {
         filterButtons
            .alpha(1)
            .enabled(true)
         backButton.hidden(true)
         infoBlock.text(Design.text.categoriesEdit)
      } else {
         filterButtons
            .alpha(0.5)
            .enabled(false)
         backButton.hidden(false)
      }
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .title(name):
         infoBlock.text(name)

      case let .popCategories(isFirst):
         pagesModel.setState(.deleteLast)
         setFirstPageState(isFirst)

      case .clearAll:
         pages.removeAll()
         pagesModel.setState(.deleteAll)
         setFirstPageState(true)

      case let .present(categories, parentCategory):
         let newPage = CategoriesEditVM<Design>(parentCategory: parentCategory)
         pages.append(newPage)
         pagesModel.setState(.addViewModel(viewModel: newPage))
         pagesModel.scrollToEnd()
         newPage.tableModel.on(\.didSelectItem, self) {
            $0.scenario.events.didSelectCategory.sendAsyncEvent($1 as! CategoryData)
         }
         newPage.cellPresenter.on(\.didTapDeleteItem, self) {
            $0.scenario.events.didTapDeleteCatetegory.sendAsyncEvent($1 as! CategoryData)
         }

         pagesModel.scrollToIndex(pages.count - 1)
         if pages.count > 1 {
            setFirstPageState(false)

         } else {
            setFirstPageState(true)
         }

//         createCategoryPopup.setState(.setParentCategory(parentCategory))
         infoBlock.text(newPage.parentCategory?.name ?? Design.text.categoriesEdit)

         guard categories.isNotEmpty else {
            setState(.hereIsEmpty)
            return
         }
         activityModel.hidden(true)
         currentPage.hereIsEmptyModel.hidden(true)
         errorModel.hidden(true)
         currentPage.tableModel.hidden(false)
         currentPage.tableModel.items(categories)

      case .loading:
         activityModel.hidden(false)
         currentPage.hereIsEmptyModel.hidden(true)
         errorModel.hidden(true)
         currentPage.tableModel.hidden(true)
      case .error:
         activityModel.hidden(true)
         currentPage.hereIsEmptyModel.hidden(true)
         errorModel.hidden(false)
         currentPage.tableModel.hidden(true)
      case .hereIsEmpty:
         activityModel.hidden(true)
         currentPage.hereIsEmptyModel.hidden(false)
         errorModel.hidden(true)
         currentPage.tableModel.hidden(true)
      case let .routeToCategory(input):
         Asset.router?.route(
            .presentModallyOnPresented(.automatic),
            scene: \.categoriesEdit,
            payload: input
         )
      case let .routeToCreateCategory(input):
         createCategoryPopup.setState(.input(input))
         bottomPopupPresenter.setState(.presentWithAutoHeight(
            model: createCategoryPopup,
            onView: vcModel?.superview
         ))
//         createCategoryPopup.setState(.setParentCategory(input.parentCategory))

      case .hideBottomPopup:
         bottomPopupPresenter.setState(.hide)
      case let .updateFilterButtonsForScope(scope):
         filterButtons
            .hidden(false)
            .setState(scope)
      case let .presentDeleteDialog(name):
         let alert = AlertViewModel<Design>(
            title: Design.text.deleteCategory + " \(name)?",
            buttons: AlertDefaultButton<Design>(text: Design.text.no).on(\.didTap, self) {
               $0.scenario.events.cancelDelete.doAsync()
               $0.alertPresenter.setState(.hide)
            }, AlertDefaultButton<Design>(text: Design.text.yes).on(\.didTap, self) {
               $0.scenario.events.confirmDelete.doAsync()
               $0.alertPresenter.setState(.hide)
            }
         )
         alertPresenter.setState(.present(model: alert, onView: vcModel?.view.superview))
      case .deleteCategoryError:
         let alert = AlertViewModel<Design>(
            title: Design.text.deleteCategoryError,
            buttons: AlertDefaultButton<Design>(text: Design.text.close).on(\.didTap, self) {
               $0.alertPresenter.setState(.hide)
            }
         )
         alertPresenter.setState(.present(model: alert, onView: vcModel?.view.superview))

      case .disableAdd:
         addCategoryButton.hidden(true)
      case .enableAdd:
         addCategoryButton.hidden(false)
      }
   }
}
