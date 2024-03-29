//
//  ChallengeInfoVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.11.2022.
//

import UIKit
import StackNinja

final class DetailsInfoVM<Design: DSP>: StackModel, Designable {
   private(set) lazy var titleLabel = Design.label.regular20
      .numberOfLines(0)
   
   private(set) lazy var bodyTextViewModel = TextViewModel()
      .backColor(Design.color.background)
   
   private(set) lazy var tagsStackModel = StackModel()
      .spacing(8)

   override func start() {
      super.start()

      arrangedModels([
         titleLabel,
         bodyTextViewModel,
         tagsStackModel
      ])
      spacing(12)
      backColor(Design.color.background)
      distribution(.equalSpacing)
      alignment(.leading)
      padding(.outline(16))
      cornerRadius(Design.params.cornerRadiusSmall)
      cornerCurve(.continuous)
      shadow(Design.params.cellShadow)
      
      configureTextView()
   }
   
   private func configureTextView() {
      bodyTextViewModel.view.textContainerInset = UIEdgeInsets.zero
      bodyTextViewModel.view.textContainer.lineFragmentPadding = 0;
      bodyTextViewModel.view.layoutManager.usesFontLeading = false
      
      bodyTextViewModel.view.dataDetectorTypes = .link
      bodyTextViewModel.view.isEditable = false
   }
}

extension DetailsInfoVM: SetupProtocol {
   struct Params {
      let name: String?
      let description: String?
      let status: String?
   }
   
   func setup(_ data: Params) {
      titleLabel.text(data.name.unwrap.trimmingCharacters(in: .whitespacesAndNewlines))
      setupBodyTextViewModel(text: data.description)
      
      if let arrayOfStates = data.status?.components(separatedBy: ", ") {
         let states = arrayOfStates
            .filter { $0 != "" }
            .map { ChallengeStatusBlock<Design>().text($0) }
         tagsStackModel.arrangedModels(states)
         tagsStackModel.hidden(false)
      } else {
         tagsStackModel.hidden(true)
      }
   }
   
   private func setupBodyTextViewModel(text: String?) {
      guard let text else {
         bodyTextViewModel.hidden(true)
         return
      }
      
      let style = NSMutableParagraphStyle()
      style.lineSpacing = 8
      
      let attributes = [
         NSAttributedString.Key.paragraphStyle: style,
         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular),
         NSAttributedString.Key.foregroundColor: Design.color.text
      ]
      
      bodyTextViewModel.hidden(false)
      bodyTextViewModel.view.attributedText = NSAttributedString(string: text, attributes: attributes)
   }
}
