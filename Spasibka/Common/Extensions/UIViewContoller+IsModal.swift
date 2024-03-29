//
//  UIViewContoller+IsModal.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.11.2022.
//

import UIKit

extension UIViewController {
   var isModal: Bool {
      let presentingIsModal = presentingViewController != nil
      let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
      let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

      return presentingIsModal || presentingIsNavigation || presentingIsTabBar
   }
}
