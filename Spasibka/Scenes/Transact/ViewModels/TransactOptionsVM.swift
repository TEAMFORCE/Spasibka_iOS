//
//  TransactOptions.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.08.2022.
//

import StackNinja
import UIKit

final class TransactOptionsVM<Design: DSP>: BaseViewModel<StackViewExtended>, Designable, Stateable {
   typealias State = StackState
   //
   lazy var anonimParamModel = LabelSwitcherXDT<Design>.switcherWith(text: Design.text.anonymously)
   lazy var isPublicSwitcher = LabelSwitcherXDT<Design>.switcherWith(text: Design.text.showForEveryone, isTurned: true)
   
   override func start() {
      arrangedModels([
         anonimParamModel,
         isPublicSwitcher
      ])
   }
}
