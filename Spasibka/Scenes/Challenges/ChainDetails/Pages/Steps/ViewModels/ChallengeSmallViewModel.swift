//
//  ChallengeSmallViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.09.2023.
//

import StackNinja
import UIKit

final class ChallengeSmallViewModel<Design: DSP>: VStackModel {
   private(set) lazy var image = ImageViewModel()
      .height(118)
      .backColor(Design.color.backgroundBrand)
      .contentMode(.scaleAspectFill)
      .addModel(
         ViewModel()
            .backColor(Design.color.constantWhite)
            .alpha(0.33)
      )

   private(set) lazy var titleBody = TitleBodyY()
      .setAll {
         $0
            .set(Design.state.label.descriptionMedium12)
            .numberOfLines(1)
            .textColor(Design.color.text)
         $1
            .set(Design.state.label.descriptionMedium10)
            .numberOfLines(1)
            .textColor(Design.color.textSecondary)
      }
      .spacing(8)

   private(set) lazy var prizeCaption = LabelModel()
      .set(Design.state.label.descriptionRegular12)

   private(set) lazy var prizeLabelIcon = Stack<LabelModel>.R<ImageViewModel>.Ninja()
      .setAll {
         $0
            .set(Design.state.label.descriptionMedium16)
            .textColor(Design.color.text)
         $1
            .size(.square(16))
      }
      .spacing(4)

   private lazy var statusLabel = LabelModel()
      .set(Design.state.label.regular10)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadiusMini)
      .height(Design.params.buttonHeightMicro)
      .textColor(Design.color.textInvert)
      .padding(.horizontalOffset(12))

   override func start() {
      super.start()

      arrangedModels(
         image.wrappedX()
            .backColor(Design.color.backgroundBrandSecondary)
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusSmall)
            .clipsToBound(true)
            .disableBottomRadius(
               Design.params.cornerRadiusSmall,
               matteColor: Design.color.background,
               isOnTop: true
            ),
         Spacer(7),
         titleBody.wrappedX()
            .padHorizontal(12)
            .height(42),
         Spacer(6),
         Wrapped3X(prizeCaption, Spacer(), prizeLabelIcon)
            .padHorizontal(12)
            .height(22),
         Spacer(12)
      )

      addModel(statusLabel) { anchors, superview in
         anchors
            .right(superview.rightAnchor, -8)
            .centerY(self.image.view.bottomAnchor, -Design.params.cornerRadiusSmall)
      }
      setNeedsStoreModelInView()
   }
}

extension ChallengeSmallViewModel: StateMachine {
   struct ModelState {
      let imageUrl: String?
      let imagePlaceHolder: UIImage
      let title: String
      let body: String
      let prizeCaption: String
      let prizeImage: UIImage
      let prizeText: String
      let status: ChallengeNewCellStatus
   }

   func setState(_ state: ModelState) {
      image.indirectUrl(state.imageUrl, placeHolder: state.imagePlaceHolder)
      titleBody.setAll {
         $0.text(state.title)
         $1.text(state.body)
      }
      prizeCaption.text(state.prizeCaption)
      prizeLabelIcon.models.main.text(state.prizeText)
      prizeLabelIcon.models.right.image(state.prizeImage)

      let isActive = state.status == .active
      switch state.status {
      case .active:
         statusLabel.text(Design.text.active)
      case .completed:
         statusLabel.text(Design.text.completed)
      case .upcoming:
         statusLabel.text(Design.text.deferred)
      case .unknown:
         statusLabel.text(Design.text.active)
      }
      statusLabel
         .backColor(isActive ? Design.color.backgroundSuccess : Design.color.backgroundInfo)
   }
}

final class ChainCurrentStepViewModel<Design: DSP>:
   Stack<ImageViewModel>
   .R<Lefted<LabelModel>>
   .R2<ButtonModel>
   .R3<ButtonModel>.Ninja
{
   var events: EventsStore = .init()

   var image: ImageViewModel { models.main }
   var label: LabelModel { models.right.subModel }
   var button1: ButtonModel { models.right2 }
   var button2: ButtonModel { models.right3 }

   required init() {
      super.init()

      setAll { image, label, button1, button2 in
         image
            .size(.square(24))
         label.subModel
            .set(Design.state.label.descriptionMedium20)
            .textColor(Design.color.text)
            .numberOfLines(1)
         button1
            .image(Design.icon.warningCircle, color: Design.color.iconContrast)
         button2
            .size(.square(24))
      }
      spacing(8)
      backColor(Design.color.background)
      padding(.init(top: 8, left: 16, bottom: 8, right: 16))
      
      button1.on(\.didTap, self) {
         $0.send(\.didTapButton1)
      }
      
      button2.on(\.didTap, self) {
         $0.send(\.didTapButton2)
      }
   }
}

extension ChainCurrentStepViewModel: Eventable {
   struct Events: InitProtocol {
      var didTapButton1: Void?
      var didTapButton2: Void?
   }
}

extension ChainCurrentStepViewModel: StateMachine {
   enum ModelState {
      case icon(UIImage)
      case title(String)
      case button1Icon(UIImage)
      case button2Icon(UIImage)
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .icon(image):
         self.image.image(image)
      case let .title(title):
         label.text(title)
      case let .button1Icon(image):
         button1.image(image)
      case let .button2Icon(image):
         button2.backImage(image)
      }
   }
}
