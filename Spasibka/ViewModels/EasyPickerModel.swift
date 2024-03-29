//
//  EasyPickerViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.04.2023.
//

import StackNinja
import UIKit

final class EasyPickerModel: BaseViewModel<UIPickerView>, UIPickerViewDelegate, UIPickerViewDataSource, Eventable {
   private var titles = [String]()

   struct Events: InitProtocol {
      var didSelectRow: Int?
   }

   var events: EventsStore = .init()

   private var textColor: UIColor?

   override func start() {
      super.start()

      view.delegate = self
      view.dataSource = self
   }

   func numberOfComponents(in _: UIPickerView) -> Int {
      1
   }

   func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
      titles.count
   }

//   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//      return titles[row]
//   }

   func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
      send(\.didSelectRow, row)
   }

   func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
      let string = titles[row]
      let attributedString = NSAttributedString(
         string: string,
         attributes: [NSAttributedString.Key.foregroundColor: textColor ?? .black]
      )
      return attributedString
   }
}

extension EasyPickerModel {
   @discardableResult func textColor(_ value: UIColor) -> Self {
      self.textColor = value
      return self
   }
}

extension EasyPickerModel: StateMachine {
   func setState(_ state: (options: [String], selectedIndex: Int)) {
      titles = state.options
      view.reloadAllComponents()
      view.selectRow(state.selectedIndex, inComponent: 0, animated: true)
   }
}
