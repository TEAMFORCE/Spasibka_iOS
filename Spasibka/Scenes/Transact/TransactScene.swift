//
//  TransactScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.02.2024.
//

import StackNinja

enum TransactSceneInput {
   case normal
   case byId(Int)
}

struct TransactSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = TransactSceneInput?
      typealias Output = Void
   }
}

final class TransactScene<Asset: ASP>: BaseParamsScene<TransactSceneParams<Asset>> {
   private(set) lazy var transactSceneViewModel = TransactSceneViewModel<Asset>(vcModel: vcModel)
//   private(set) lazy var transactSceneVM = TransactSceneViewModel(vcModel: vcModel)
   override func start() {
      vcModel?.on(\.viewWillAppear, self) {
         $0.vcModel?
            .titleColor(Design.color.transparent)
            .navBarTintColor(Design.color.transparent)
            .titleAlpha(0)
      }
      mainVM.navBar.titleLabel.text(Design.text.newTransact)
//      mainVM.navBar.backColor(.blue)
      mainVM.bodyStack
         .arrangedModels(transactSceneViewModel)
      transactSceneViewModel.scenarioStart()
      if let input = inputValue {
         switch input {
         case let .byId(id):
            transactSceneViewModel.setSelectedUser(id: id)
         case .normal:
            break
         case .none:
            break
         }
      }
      
   }
}
