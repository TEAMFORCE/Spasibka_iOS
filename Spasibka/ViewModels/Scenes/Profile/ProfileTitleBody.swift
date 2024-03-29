//
//  ProfileTitleBody.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 07.12.2022.
//

import StackNinja
import UIKit

// MARK: - ProfileTitleBody

final class ProfileTitleBody<Design: DSP>: Stack<LabelModel>.D<LabelModel>.Ninja, Designable {
   var title: LabelModel { models.main }

   func setBody(_ text: String?) {
      guard let text, text != "" else { hidden(true); return }

      models.down.text(text)
      hidden(false)
   }

   required init() {
      super.init()

      setAll { title, body in
         title
            .set(Design.state.label.regular12Secondary)
         body
            .set(Design.state.label.regular14)
      }

      spacing(8)
   }
}

final class ProfileTitleBody2<Design: DSP>: Stack<LabelModel>.D<TextViewModel>.Ninja, Designable {
   var title: LabelModel { models.main }

   func setBody(_ text: String?) {
      guard let text, text != "" else { hidden(true); return }

      models.down.text(text)
      hidden(false)
   }

   required init() {
      super.init()

      setAll { title, body in
         title
            .set(Design.state.label.regular12Secondary)
         body
            .set(Design.state.label.regular14)
            .backColor(Design.color.background)
      }

      spacing(8)
      
      models.down.view.textContainerInset = UIEdgeInsets.zero
      models.down.view.textContainer.lineFragmentPadding = 0;
      models.down.view.layoutManager.usesFontLeading = false
      models.down.view.isEditable = false
   }
}
