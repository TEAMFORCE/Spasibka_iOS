//
//  BaseFilterPopupScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

import StackNinja

struct FilterSceneEvents<FilterResult>: InitProtocol {
   var cancelled: Void?
   var finishFiltered: FilterResult?
}

class BaseFilterPopupScene<Asset: ASP, FilterResult>: ModalDoubleStackModel<Asset>, Eventable {
   
   typealias Events = FilterSceneEvents<FilterResult>
   
   var events = EventsStore()
   
   private(set) lazy var applyFilterButton = ButtonModel()
      .set(Design.state.button.default)
      .title(Design.text.apply)
   
   private(set) lazy var clearFilterButton = ButtonModel()
      .set(Design.state.button.transparent)
      .title(Design.text.reset)
   
   override func start() {
      super.start()
      
      title.text(Design.text.filter)
      set(Design.state.stack.default)
      cornerRadius(Design.params.cornerRadiusBig)
      cornerCurve(.continuous)
      
      footerStack
         .arrangedModels(
            applyFilterButton,
            clearFilterButton
         )
   }
}
