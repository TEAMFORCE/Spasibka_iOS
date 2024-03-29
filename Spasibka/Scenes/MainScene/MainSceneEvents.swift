//
//  MainSceneEvents.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.08.2022.
//

import CoreGraphics
import StackNinja

struct MainSceneEvents<Payload>: InitProtocol {
   var didScroll: CGFloat?
   var willEndDragging: CGFloat?
   var payload: Payload?
   var updateTitle: String?

   var presentRecievedHistory: Void?
   var presentSentHistory: Void?
   var presentMarketFilterScene: Void?
}
