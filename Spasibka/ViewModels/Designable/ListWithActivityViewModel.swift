//
//  ListWithActivityViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.09.2023.
//

import StackNinja

final class ListWithActivityViewModel<Design: DSP>: VStackModel, Designable, ActivityViewModelProtocol {
   var events = EventsStore()

   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   private(set) lazy var tableModel = TableItemsModel()
      .backColor(Design.color.background)
      .footerModel(Spacer(64))

   override func start() {
      super.start()

      arrangedModels([
         activityBlock,
         tableModel,
         Spacer()
      ])

      activityState(.loading)
      
      tableModel.on(\.didSelectItemAtIndex, self) {
         $0.send(\.didSelectItemAtIndex, $1)
      }
   }
}

extension ListWithActivityViewModel: Eventable {
   struct Events: InitProtocol {
      var didSelectItemAtIndex: Int?
   }
}

extension ListWithActivityViewModel: StateMachine {
   enum ModelState {
      case presenter(PresenterProtocol)
      case items([Any])
      case itemSections([TableItemsSection])
      case error
      case headerModelFactory((Int, TableItemsSection) -> UIViewModel)
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .presenter(presenter):
         tableModel.presenters(presenter)
      case let .items(items):
         guard items.isNotEmpty else {
            activityBlock.setState(.empty)
            tableModel.hidden(true)
            return
         }

         activityBlock.setState(.hidden)
         tableModel
            .hidden(false)
            .items(items)
      case let .itemSections(sections):
         guard sections.isNotEmpty else {
            activityBlock.setState(.empty)
            tableModel.hidden(true)
            return
         }

         activityBlock.setState(.hidden)
         tableModel
            .hidden(false)
            .itemSections(sections)
      case .error:
         activityBlock.setState(.error)
      case let .headerModelFactory(factory):
         tableModel
            .headerModelFactory(factory)
      }
   }
}
