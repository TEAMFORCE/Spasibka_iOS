//
//  SlidedIndexButtons.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 04.02.2023.
//

import StackNinja

final class SlidingManyButtons<ButtEvents: ManyButtonEvent>: BaseViewModel<ScrollViewExtended>,
                                                             IndexedButtonsProtocol,
                                                             Stateable
{
   typealias State = ScrollState
   typealias Events = ManyButtonsTapEvent<ButtEvents>
   
   var events: EventsStore = .init()
   var buttons: [any ModableButtonModelProtocol] = []
   var selectedIndex: Int = 0
   
   private(set) lazy var stack = StackModel()
      .axis(.horizontal)
   
   init(buttons: any ModableButtonModelProtocol...) {
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
               guard let event = ButtEvents(rawValue: tuple.offset) else { return }
               
               slf.setButtonTapped(event)
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
   
   func setSelectedButton(_ index: Int) {
      if buttons.indices.contains(index) {
         buttons.forEach { but in but.setMode(\.normal) }
         buttons[index].setMode(\.selected)
         selectedIndex = index
      }
   }
   
   func setButtonTapped(_ event: ButtEvents) {
      buttons.forEach { but in but.setMode(\.normal) }
      
      let index = event.rawValue
      buttons[index].setMode(\.selected)
      selectedIndex = index
      send(\.didTapButtons, event)
   }
   
   required init() {
      fatalError("init() has not been implemented")
   }
}

struct ManyButtonsTapEvent<M: ManyButtonEvent>: InitProtocol {
   var didTapButtons: M?
}
