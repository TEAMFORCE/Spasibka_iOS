//
//  TemplateCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.05.2023.
//

import StackNinja

final class TemplateCellEventablePresenter<Design: DSP>: Eventable {
   struct Events: InitProtocol {
      var didTapEditTemplateAtIndex: Int?
   }

   var events = EventsStore()

   var presenter: CellPresenterWork<ChallengeTemplate, StackModel> { .init { work in
      let template = work.in.item
      let index = work.in.indexPath.row
      let cell = TemplateNewCell<Design>()

      cell.setState(.init(
         titleText: template.name.unwrap,
         imageUrl: SpasibkaEndpoints.tryConvertToImageUrl(template.photo),
         typeText: template.challengeType == "default" ? Design.text.challenge : Design.text.challengeChains,
         tagTexts: template.sections.unwrap.map { $0.name }
      ))

      cell.editButton.on(\.didTap, self) {
         $0.send(\.didTapEditTemplateAtIndex, index)
      }

      work.success(
         cell.wrappedX()
            .padHorizontal(12+16)
            .padTop(16)
            .padBottom(32)
            .backViewModel(
               ViewModel()
                  .cornerRadius(Design.params.cornerRadiusBig)
                  .cornerCurve(.continuous)
                  .backColor(Design.color.background)
                  .shadow(Design.params.templateCellShadow),
               inset: .init(top: 0, left: 16, bottom: 16, right: 16)
            )
      )
   } }
}

import UIKit

final class TemplateNewCell<Design: DSP>:
   Stack<HStackModel>
   .D<ImageViewModel>
   .D2<LabelModel>
   .D3<ScrollStackedModelX>
   .Ninja
{
   private(set) lazy var typeLabel = BorderedRadiusLabel<Design>()
   private(set) lazy var editButton = ButtonModel()
      .size(.square(24))
      .cornerRadius(8)
      .cornerCurve(.continuous)
      .borderColor(Design.color.backgroundBrandSecondary)
      .borderWidth(2)
      .image(Design.icon.tablerEditCircle, color: Design.color.iconBrand)
      .imageInset(.outline(2))
      .backColor(Design.color.backgroundBrandSecondary)

   var imageModel: ImageViewModel { models.down }
   var titleModel: LabelModel { models.down2 }
   var scrollModel: ScrollStackedModelX { models.down3 }

   required init() {
      super.init()

      setAll { topPanel, image, title, scrollPanel in
         topPanel
            .distribution(.fill)
            .spacing(16)
            .arrangedModels(typeLabel, Spacer(), editButton)

         image
            .height(212.aspectedByHeight > 212 ? 212 : 212.aspectedByHeight)
            .backColor(Design.color.backgroundBrandSecondary)
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusBig)
            .contentMode(.scaleAspectFit)
            .image(Design.icon.challengeWinnerIllustrate)
            .addModel(
               ViewModel()
                  .backColor(Design.color.constantBlack)
                  .alpha(0.33)
            ) { $0.fitToView($1) }

         title
            .set(Design.state.label.semibold16)
            .numberOfLines(2)

         scrollPanel
            .spacing(4)
            .hideHorizontalScrollIndicator()
      }
      spacing(16)
      setNeedsStoreModelInView()
   }
}

extension TemplateNewCell: StateMachine {
   struct ModelState {
      let titleText: String
      let imageUrl: String?
      let typeText: String
      let tagTexts: [String]
   }

   func setState(_ state: ModelState) {
      titleModel.text(state.titleText)
      if let imageUrl = state.imageUrl {
         imageModel.presentActivityModel(Design.model.common.activityIndicator)
         imageModel.indirectUrl(imageUrl) { model, _ in
            model?.contentMode(.scaleAspectFill)
            model?.hideActivityModel()
         }
      }
      typeLabel.text(state.typeText)
      scrollModel.arrangedModels(state.tagTexts.map {
         BorderedRadiusLabel<Design>()
            .text($0)
            .borderColor(Design.color.iconBrand)
      })
   }
}

final class BorderedRadiusLabel<Design: DSP>: LabelModel {
   override func start() {
      super.start()

      set(Design.state.label.regular12)
         .borderWidth(1)
         .cornerRadius(Design.params.cornerRadiusMini)
         .cornerCurve(.continuous)
         .padding(.horizontalOffset(8))
         .height(24)
         .alignment(.center)
   }

   func set(text: String, borderColor: UIColor) {
      self
         .text(text)
         .borderColor(borderColor)
   }
}
