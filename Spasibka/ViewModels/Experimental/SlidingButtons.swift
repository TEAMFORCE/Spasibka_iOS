//
//  SlidingButtons.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 16.09.2023.
//

import StackNinja

struct TapIndexEvents: InitProtocol {
   var didTapButtonAtIndex: Int?
}

final class SlidingButtons: BaseViewModel<ScrollViewExtended>,
                            Stateable, Eventable
{
   typealias State = ScrollState
   typealias Events = TapIndexEvents
   
   var events: EventsStore = .init()
   private(set) var buttons: [any ModableButtonModelProtocol] = []

   lazy var stack = StackModel()
      .axis(.horizontal)

   init(buttons: [any ModableButtonModelProtocol]) {
      super.init()

      guard buttons.isEmpty == false else { return }
      self.buttons = buttons
      configure()
   }
   
   private func configure() {
      buttons.first?.setMode(\.selected)
      buttons.enumerated().forEach { tuple in
         tuple.element
            .on(\.didTap, self) { slf in
               slf.forceTapButtonAt(tuple.offset)
            }
      }
      
      stack
         .spacing(Grid.x8.value)
         .alignment(.center)
         .arrangedModels(buttons)
      view.addSubview(stack.uiView)
      
      stack.view.addAnchors
         .top(view.topAnchor)
         .leading(view.leadingAnchor)
         .trailing(view.trailingAnchor)
         .height(view.heightAnchor)
      
      view.layer.masksToBounds = false
      view.clipsToBounds = false
      view.showsHorizontalScrollIndicator = false
   }
   
   func selectButtonAt(_ index: Int) {
      if buttons.indices.contains(index) {
         buttons.forEach { but in but.setMode(\.normal) }
         buttons[index].setMode(\.selected)
      }
   }
   
   func forceTapButtonAt(_ index: Int) {
      buttons.forEach { but in but.setMode(\.normal) }
      
      if buttons.indices.contains(index) {
         buttons[index].setMode(\.selected)
      }
      
      send(\.didTapButtonAtIndex, index)
   }
   
   func setButtons(_ buttons: [any ModableButtonModelProtocol]) {
      self.buttons = buttons
      configure()
   }

   required init() {
      fatalError("init() has not been implemented")
   }
}
