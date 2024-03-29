//
//  CategoryCreateScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

struct CreateCategoryInput {
   let categories: [CategoryData]
   let scope: ChallengeTemplatesScope
   let parentCategory: CategoryData?
}

final class CreateCategoryPopup<Asset: ASP>: ModalDoubleStackModel<Asset>, Scenarible {

   let finishWork = Out<CreateCategoryResponse>()

   lazy var scenario = CreateCategoryScenario(
      works: CreateCategoryWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         initial: .init(),
         didEditingCategoryName: categoryNameTextField.on(\.didEditingChanged),
         didSelectParentCategory: cellPresenter.on(\.didCheckmarked),
         didTapCreateCategory: createButton.on(\.didTap)
      )
   )

   private let parentCategoryTitle = Design.text.parentCategories
   private lazy var parentCategoriesLabel = LabelModel()
      .set(Design.state.label.regular14)
      .textColor(Design.color.textSecondary)
      .padBottom(16)

   private lazy var cellPresenter = CreateCategoryCellPresenter<Design>()
   private lazy var tableModel = TableItemsModel()
      .presenters(cellPresenter.presenter)
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private lazy var categoryNameTextField = TextFieldModel()
      .set(Design.state.textField.default)
      .placeholder(Design.text.categoryName)
      .padding(.horizontalOffset(16))

   private(set) lazy var createButton = ButtonModel()
      .set(Design.state.button.inactive)
      .title(Design.text.create)

   private lazy var darkLoader = DarkLoaderVM<Design>()
   private lazy var errorPopup = Design.model.common.systemErrorPopup
   private lazy var centerPopupPresenter = CenterPopupPresenter()

   override func start() {
      super.start()

      title.text(Design.text.createCategory)

      bodyStack
         .arrangedModels(
            parentCategoriesLabel,
            tableModel,
            Spacer(24),
            Spacer()
         )

      footerStack
         .spacing(8)
         .arrangedModels(
            categoryNameTextField,
            createButton
         )

      scenario.configureAndStart()
   }
}

enum CreateCategoryState {
   case input(CreateCategoryInput)
   case presentParentCategories([SelectWrapper<CategoryData>])

   case loading
   case finish(CreateCategoryResponse)
   case error

   case updateSelectedCount(Int)
   case createButtonEnabled
   case createButtonDisabled

   case setParentCategory(CategoryData?)
}

extension CreateCategoryPopup: StateMachine {
   func setState(_ state: CreateCategoryState) {
      switch state {
      case let .input(input):
         scenario.events.initial.sendAsyncEvent(input)
      case let .presentParentCategories(categories):
         guard categories.isNotEmpty else {
            tableModel.hidden(true)
            parentCategoriesLabel.hidden(true)
            return
         }
         tableModel.hidden(false)
         parentCategoriesLabel
            .hidden(false)
            .text(parentCategoryTitle)
         tableModel.items(categories)
      case .createButtonEnabled:
         createButton.set(Design.state.button.default)
      case .createButtonDisabled:
         createButton.set(Design.state.button.inactive)
      case let .updateSelectedCount(count):
         parentCategoriesLabel.text(parentCategoryTitle + " (\(count))")
      case .loading:
         darkLoader.setState(.loading(onView: rootSuperview))
      case .finish(let response):
         closeButton.send(\.didTap)
         darkLoader.setState(.hide)
         finishWork.sendAsyncEvent(response)
      case .error:
         darkLoader.setState(.hide)
         centerPopupPresenter.setState(.present(model: errorPopup, onView: rootSuperview))
         errorPopup.on(\.didClosed, self) {
            $0.centerPopupPresenter.setState(.hide)
         }
      case .setParentCategory(let category):
         scenario.events.setParentCategory.sendAsyncEvent(category)
      }
   }
}
