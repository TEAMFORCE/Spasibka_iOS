//
//  MultipageScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja
import UIKit

protocol MultipageScene: Scenarible, Assetable {
   associatedtype PageKey: Hashable
   associatedtype PageEvents: InitProtocol
   associatedtype Payload
   
   var pageNinjaViewModel: PageNinjaViewModel<PageKey, PageEvents, Payload> { get }
   
   func bindPageEvents()
}

//extension MultipageScene where Self: HeaderAnimatedSceneProtocol, PageEvents: ScrollEventsProtocol {
//   func bindPageEvents() {
//      pageNinjaViewModel.on(\.willEndDragging, self) {
//         if $1.velocity <= 0, !$0.isHeaderPresented {
//            $0.presentHeader()
//         } else if $1.velocity > 0, $0.isHeaderPresented {
//            $0.hideHeader()
//         }
//      }
//   }
//}
