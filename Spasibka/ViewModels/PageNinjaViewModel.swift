//
//  pageNinjaViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 16.09.2023.
//

import StackNinja
import UIKit

// MARK: - New

final class PageNinjaViewModel<ButtonKey: Hashable, Events: InitProtocol, Payload>: VStackModel, Eventable {
   typealias Model = ViewModelWrapperProtocol & PayloadedScenarible & Eventable
   typealias PageModel = (buttonTitle: String, key: ButtonKey, model: any Model, isHidden: Bool)

   var events = EventsStore() {
      didSet {
         pageModels.forEach { pageModel in
            pageModel.model.events = events
         }
      }
   }

   private let pageModels: [PageModel]
   private let slidingButtons: SlidingButtons

   private let pagingViewModel = PagingScrollViewModel()

   private var payload: Payload?

   init(_ pageModels: [PageModel], buttonFabric: (String) -> any ModableButtonModelProtocol) {
      let buttons = pageModels.map { buttonFabric($0.buttonTitle) }
      slidingButtons = SlidingButtons(buttons: buttons)
      self.pageModels = pageModels

      super.init()

      arrangedModels(WrappedX(slidingButtons).padHorizontal(16), pagingViewModel)
      spacing(16)

      let viewModels = pageModels.map { $0.model.viewModel }
      pagingViewModel
         .setStates(.setViewModels(viewModels))
         .on(\.didViewModelPresented, self) {
            $0.slidingButtons.selectButtonAt($1.index)
            if let payload = $0.payload {
               let pageModel = $0.pageModels[$1.index].model
               pageModel.startWithGenericPayload(payload)
            }
         }

      pageModels.forEach {
         if $0.isHidden {
            setPageHidden($0.key, hidden: $0.isHidden)
         }
      }
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   override func start() {
      super.start()

      slidingButtons.on(\.didTapButtonAtIndex, self) { (slf, index: Int) in
         slf.pagingViewModel.scrollToIndex(index)
      }
   }

   func reload() {
      pagingViewModel.reload()
   }

   func setPayload(_ payload: Payload) {
      self.payload = payload
   }

   func setPayloadToAllPagesAndStartScenario(_ payload: Payload) {
      setPayload(payload)
      pageModels.forEach {
         $0.model.startWithGenericPayload(payload)
      }
   }

   func setPayloadToPageAndStartScenario(_ key: ButtonKey, payload: Payload) {
      setPayload(payload)

      guard let index = pageModels.firstIndex(where: { $0.key.hashValue == key.hashValue }) else {
         return
      }

      pageModels[index].model.startWithGenericPayload(payload)
   }
   
   func setPayloadToCurrentPageAndStartScenario(payload: Payload) {
      setPayload(payload)
      
      pageModels[safe: pagingViewModel.currentPage]?.model.startWithGenericPayload(payload)
   }

   func scrollToPage(_ key: ButtonKey, payload: Payload? = nil, animationDuration: CGFloat = 0.3) {
      guard let index = pageModels.firstIndex(where: { $0.key.hashValue == key.hashValue }) else {
         return
      }

      if let payload {
         setPayloadToPageAndStartScenario(key, payload: payload)
      }
      slidingButtons.selectButtonAt(index)
      pagingViewModel.scrollToIndex(index, animationDuration: animationDuration)
   }

   func setPageHidden(_ key: ButtonKey, hidden: Bool) {
      guard let index = pageModels.firstIndex(where: { $0.key.hashValue == key.hashValue }) else {
         return
      }

      slidingButtons.buttons[index].hidden(hidden)
      pagingViewModel.models[index].uiView.isHidden = hidden
      pagingViewModel.reload()
   }
   
   func getStateMachine<T: StateMachine>(_ key: ButtonKey, type: T.Type) -> T? {
      guard let index = pageModels.firstIndex(where: { $0.key.hashValue == key.hashValue }) else {
         return nil
      }
      
      return pageModels[index].model as? T
   }
   
   func setStateToPage<T: StateMachine>(_ key: ButtonKey, type: T.Type, state: T.ModelState) {
      guard let index = pageModels.firstIndex(where: { $0.key.hashValue == key.hashValue }) else {
         return
      }
      
      let model = pageModels[index].model as? T
      model?.setState(state)
   }
}
