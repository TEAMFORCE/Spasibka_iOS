//
//  IconLabelHorizontalModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import StackNinja
import UIKit

enum IconLabelState {
   case icon(UIImage)
   case text(String)
}

struct IconLabelHorizontalModelEvents: InitProtocol {
   var didTap: Void?
}

final class IconLabelX<Asset: AssetProtocol>: BaseViewModel<StackViewExtended>,
   Assetable, Eventable
{
   typealias Events = IconLabelHorizontalModelEvents
   var events = EventsStore()

   let label = Design.label.bold14
   let icon = ImageViewModel()

   
   required init() {
      super.init()
   }

   override func start() {
      set(.axis(.horizontal))
      set(.alignment(.center))
      set(.arrangedModels([
         icon,
         Spacer(20),
         label,
         Spacer()
      ]))

      let gesture = UITapGestureRecognizer(target: self, action: #selector(clickAction(sender:)))
      view.addGestureRecognizer(gesture)
   }

   @objc private func clickAction(sender: UITapGestureRecognizer) {
      send(\.didTap)
      print("Did tap1")
   }
}

extension IconLabelX: Stateable2 {
   typealias State = StackState

   func applyState(_ state: IconLabelState) {
      switch state {
      case .icon(let uIImage):
         icon.set(.image(uIImage))
      case .text(let string):
         label.set(.text(string))
      }
   }
}
