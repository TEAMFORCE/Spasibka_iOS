//
//  BalanceCellModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 04.12.2023.
//

import StackNinja
import UIKit

enum BalanceCellState {
   case text(String)
   case header(String)
   case caption(String)
   case burn(title: String, body: String)
}

final class BalanceCellModelDT<Design: DesignProtocol>: BaseViewModel<StackViewExtended>,
   Designable
{
   typealias State = StackState

   private let darkenColor = 0.23

   private lazy var backLogo = ChostBackLogo<Design>(size: 96.aspected)
      .padding(.shift(.init(x: 50, y: -10)))
      .setup {
         $0.logo.backColor(color.darkenColor(darkenColor))
      }

   private lazy var headerLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var textLabel = Design.label.descriptionRegualer64
      .textColor(Design.color.textInvert)
   private lazy var captionLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var burnLabel = TitleBodyX()
      .setAll { title, body in
         title
            .set(Design.state.label.medium14)
            .textColor(Design.color.textInvert)
         body
            .set(Design.state.label.medium8)
            .numberOfLines(2)
            .textColor(Design.color.textInvert)
      }
      .alignment(.center)
      .spacing(8)
      .backColor(Design.color.background.withAlphaComponent(0.2))
      .cornerCurve(.continuous)
      .cornerRadius(7)
      .padding(.init(top: 4, left: 8, bottom: 4, right: 8))
      .hidden(true)
      .addArrangedModel(Spacer())

   private let color: UIColor

   init(color: UIColor) {
      self.color = color
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   override func start() {
      axis(.vertical)
      padding(.init(top: 36, left: 18, bottom: 14, right: 18))
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusBig)
      height(245)
      arrangedModels([
         headerLabel,
         Spacer(10),
         textLabel,
         Spacer(8),
         burnLabel.lefted().height(30),
         Spacer(),
         captionLabel,
      ])
      gradient(
         .init(
            colors: [color,
                     color.darkenColor(darkenColor)],
            startPoint: .zero,
            endPoint: .init(x: 1, y: 0)
         ),
         size: .init(width: UIScreen.main.bounds.width / 2,
                     height: UIScreen.main.bounds.width / 2)
      )
      addModel(backLogo.alpha(0.3), setup: { $0.fitToView($1) })
      clipsToBound(true)
      maskToBounds(true)
   }
}

extension BalanceCellModelDT: Stateable2 {
   func applyState(_ state: BalanceCellState) {
      switch state {
      case let .text(string):
         textLabel.set(.text(string))
      case let .header(string):
         headerLabel.set(.text(string))
      case let .caption(string):
         captionLabel.set(.text(string))
      case let .burn(string, body):
         burnLabel.title.text(string)
         burnLabel.body.text(body)
         burnLabel.hidden(false)
      }
   }
}
