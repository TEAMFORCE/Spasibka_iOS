//
//  PreviewWrapper.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja
import UIKit

final class PreviewModelWrapper<VM: UIViewModel>: UIViewController {
   
   private let viewModel: VM
   
   init(_ viewModel: VM) {
      self.viewModel = viewModel
      super.init(nibName: nil, bundle: nil)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      let subview = viewModel.uiView
      subview.addToSuperview(view)
         .fitToView(view)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

//final class PreviewSceneWrapper<Scene: BaseScene<I, O>, I, O>: UIViewController {
//   
//   private let scene: BaseScene<I, O>
//   
//   init(_ scene: BaseScene<I, O>) {
//      self.scene = scene
//      super.init(nibName: nil, bundle: nil)
//   }
//   
//   override func viewDidLoad() {
//      super.viewDidLoad()
//      
//      let subview = scene.makeVC()
//      subview.addToSuperview(view)
//         .fitToView(view)
//   }
//   
//   required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//   }
//}
