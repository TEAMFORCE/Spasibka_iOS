//
//  ReactionButton.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import StackNinja
import CoreFoundation

enum SelectState {
   case none
   case selected
   case loading
}

final class ReactionButton<Design: DSP>: Stack<ImageViewModel>.R<LabelModel>.Ninja, Designable {
   
   var textLabel: LabelModel { models.right }
   var amountText: String = "" {
      willSet(value) {
         if value == "0" {
            self.amountText = ""
            textLabel.hidden(true)
         } else {
            textLabel.hidden(false)
            textLabel.text(value)
         }
      }
   }

   required init() {
      super.init()

      setAll {
         $0
            .size(.square(Grid.x16.value))
            .imageTintColor(Design.color.textContrastSecondary)
         $1
            .set(Design.state.label.descriptionMedium12)
            .textColor(Design.color.textContrastSecondary)
      }
      distribution(.equalCentering)
      cornerRadius(Design.params.cornerRadiusMini)
      cornerCurve(.continuous)
      maxWidth(100)
      height(24)
      padding(.horizontalOffset(6))
      spacing(6)

      setState(.none)
   }
}

extension ReactionButton: StateMachine {
   func setState(_ state: SelectState) {
//      userInterractionEnabled(true)
      hideActivityModel()
      models.main.hidden(false)
      models.right.hidden(false)
      switch state {
      case .none:
         models.main.image(Design.icon.heart)
         models.main.imageTintColor(Design.color.textContrastSecondary)
         models.right.textColor(Design.color.textContrastSecondary)
         backColor(Design.color.backgroundInfoSecondary)
      case .selected:
         models.main.imageTintColor(Design.color.iconError)
         models.main.image(Design.icon.redHeart)
         models.right.textColor(Design.color.textError)
         backColor(Design.color.backgroundErrorSecondary)
      case .loading:
         models.main.hidden(true)
         models.right.hidden(true)
//         userInterractionEnabled(false)
         presentActivityModel(ActivityIndicator<Design>())
      }
   }
}


final class NewLikeButton<Design: DSP>: ImageViewModel, Designable {

   required init() {
      super.init()

      size(.init(width: 42.34, height: 36))
      imageTintColor(Design.color.textContrastSecondary)
      

      setState(.none)
   }
}

extension NewLikeButton: StateMachine {
   func setState(_ state: SelectState) {
//      userInterractionEnabled(true)
      hideActivityModel()
      hidden(false)
      switch state {
      case .none:
         image(Design.icon.heart.insetted(2))
         imageTintColor(Design.color.textContrastSecondary)
      case .selected:
         imageTintColor(Design.color.iconError)
         image(Design.icon.redHeart.insetted(2))
      case .loading:
         hidden(true)
//         userInterractionEnabled(false)
         presentActivityModel(ActivityIndicator<Design>())
      }
   }
}

final class ThanksAmountModel<Design: DSP>: Stack<LabelModel>.R<ImageViewModel>.Ninja, Designable {
   
   var textLabel: LabelModel { models.main }
   
   var amountText: String = "" {
      willSet(value) {
         if let intValue = value.toInt {
            if intValue > 9 {
               padding(.horizontalOffset(3))
            } else {
               padding(.horizontalOffset(6))
            }
         }
         textLabel.text(value)
      }
   }

   required init() {
      super.init()

      setAll {
         $0
            .set(Design.state.label.regular16)
            .textColor(Design.color.text)
         $1
            .size(.square(Grid.x16.value))
            .imageTintColor(Design.color.iconBrand)
            .image(Design.icon.smallSpasibkaLogo)
      }
      distribution(.equalCentering)
      spacing(1)
      padding(.horizontalOffset(6))

   }
}
