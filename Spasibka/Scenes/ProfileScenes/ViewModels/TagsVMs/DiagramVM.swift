//
//  DiagramVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - DiagramVM

final class DiagramVM: BaseViewModel<GraphView> {
   override func start() {}
}

extension DiagramVM: Stateable {
   typealias State = ViewState
}

extension DiagramVM: StateMachine {
   func setState(_ state: [GraphData]) {
      view.drawGraphs(state)
   }
}
