//
//  BenefitsViewModels.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.01.2023.
//

import StackNinja
import UIKit

final class BenefitsViewModel<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didSelectBenefit: Int?
      var didTapSearchButton: String?
      var didSelectBenefitWithId: Int?
   }

   var events: EventsStore = .init()

   var searchField: TextFieldModel { searchModel.subModel.models.main }

   var searchButton: ButtonModel { searchModel.subModel.models.right }

   var segmentControl = ScrollableSegmentControl<Design>()

   lazy var presenters = BenefitCellPresenters<Design>()
   
   lazy var benefitsTable = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenters.pairPresenter
      )
      .setNeedsLayoutWhenContentChanged()

   lazy var filterButton = ButtonModel()
      .size(.square(24))
      .image(Design.icon.filterIcon)
   
   // Private
   private lazy var searchModel = WrappedX<M<TextFieldModel>.R<ButtonModel>.Ninja>()
      .padding(.bottom(12))
      .spacing(20)
      .setup {
         $0.subModel
            .setAll { textField, button in
               textField
                  .placeholder(Design.text.searchProduct)
                  .placeholderColor(Design.color.textContrastSecondary)
                  .font(Design.font.descriptionRegular14)
                  .textColor(Design.color.text)
                  
               button
                  .image(Design.icon.searchIcon.withTintColor(Design.color.text))
                  .size(.square(18))
//                  .backImage(Design.icon.searchIcon.withTintColor(Design.color.text))
            }
            .height(48)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .borderColor(Design.color.iconMidpoint)
            .borderWidth(1)
            .padding(.outline(12))
      }

   override func start() {
      super.start()

      arrangedModels([
         searchModel,
         filterButton.righted(),
         Spacer(20),
         benefitsTable,
         Spacer(),
      ])

      
      presenters
         .on(\.cellPressed, self) {
            $0.send(\.didSelectBenefitWithId, $1)
         }

      searchButton.on(\.didTap, self) {
         $0.send(\.didTapSearchButton, $0.searchField.view.text ?? "")
      }
   }
}

enum BenefitsViewModelState {
   case presentBenefits([Benefit])
   case hideFilter
   case presentFilter
   case setCategories([String])
   case updateSelectedCategory(Int)
}

extension BenefitsViewModel: StateMachine {
   func setState(_ state: BenefitsViewModelState) {
      switch state {
      case let .presentBenefits(benefits):
         benefitsTable.items(benefits.splitByPairs)
      case .hideFilter:
         UIView.animate(withDuration: 0.5) {
            self.searchModel.hidden(true)
            self.segmentControl.hidden(true)
         }
      case .presentFilter:
         UIView.animate(withDuration: 0.5) {
            self.searchModel.hidden(false)
            self.segmentControl.hidden(false)
         }
      case let .setCategories(categories):
         var buttons: [BenefitFilterButton<Design>] = []
         for category in categories {
            let button = BenefitFilterButton<Design>()
               .setStates(
                  .text(category),
                  .image(Design.icon.tablerCategory2)
               )
            buttons.append(button)
         }
         segmentControl.setState(.buttons(buttons))
      case let .updateSelectedCategory(id):
         segmentControl.setState(.selectOneCategory(id))
         
      }
   }
}

final class BenefitFilterButton<Design: DSP>: Stack<WrappedX<ImageViewModel>>.D<LabelModel>.D2<Spacer>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State = StackState
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { imageWrapper, label, _ in
         imageWrapper
            .size(.square(64))
            .backColor(Design.color.backgroundInfoSecondary)
            .cornerCurve(.continuous).cornerRadius(64 / 2)
            .padding(.outline(16))
            .subModel
            .imageTintColor(Design.color.iconBrand)

         label
            .alignment(.center)
            .set(Design.state.label.regular12)
            .numberOfLines(2)
      }
      alignment(.center)
      spacing(8)
      width(80)
      height(40 + 64 + 8)

      onModeChanged(\.normal) { [weak self] in
         self?.models.main.backColor(Design.color.backgroundInfoSecondary)
      }
      onModeChanged(\.selected) { [weak self] in
         self?.models.main.backColor(Design.color.backgroundBrandSecondary)
      }

      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}

enum BenefitFilterButtonState {
   case text(String)
   case image(UIImage)
}

extension BenefitFilterButton: StateMachine {
   func setState(_ state: BenefitFilterButtonState) {
      switch state {
      case let .text(text):
         models.down
            .text(text)
            .kerning(-0.66)
      case let .image(image):
         models.main.subModel.image(image)
      }
   }
}
