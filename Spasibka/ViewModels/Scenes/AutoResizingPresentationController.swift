//
//  BottomScheetVCModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.02.2024.
//

import UIKit
import StackNinja

final class AutoResizingPresentationController: UIPresentationController {
   private var dimmingView: UIView!

   override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      configureDimmingView()
   }

   private func configureDimmingView() {
      dimmingView = UIView()
      dimmingView.translatesAutoresizingMaskIntoConstraints = false
      dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
      dimmingView.alpha = 0.0
      dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDimmingView)))
   }

   override var frameOfPresentedViewInContainerView: CGRect {
      guard let containerView = containerView, let presentedView = presentedView else {
         return .zero
      }

      presentedView.layoutIfNeeded()
      let contentSize = presentedView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
      let yOffset = containerView.bounds.height - contentSize.height

      return CGRect(x: 0, y: yOffset, width: containerView.bounds.width, height: contentSize.height)
   }

   override func presentationTransitionWillBegin() {
      guard let containerView = containerView else { return }

      containerView.addSubview(dimmingView)
      dimmingView.frame = containerView.bounds

      if let transitionCoordinator = presentingViewController.transitionCoordinator {
         transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
         }, completion: nil)
      }

      let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissSwipe(_:)))
      self.presentedView?.addGestureRecognizer(swipeGesture)
   }

   override func dismissalTransitionWillBegin() {
      if let transitionCoordinator = presentingViewController.transitionCoordinator {
         transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
         }, completion: nil)
      }
   }

   override func dismissalTransitionDidEnd(_ completed: Bool) {
      if completed {
         dimmingView.removeFromSuperview()
      }
   }

   @objc private func didTapDimmingView() {
      presentingViewController.dismiss(animated: true, completion: nil)
   }

   @objc private func handleDismissSwipe(_ gesture: UIPanGestureRecognizer) {
      let translation = gesture.translation(in: presentedView)
      let velocity = gesture.velocity(in: presentedView)

      if translation.y > 0 && velocity.y > 0 {
         self.presentingViewController.dismiss(animated: true, completion: nil)
      }
   }
}


final class AutoResizingTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
   func presentationController(
      forPresented presented: UIViewController,
      presenting: UIViewController?,
      source _: UIViewController
   ) -> UIPresentationController? {
      return AutoResizingPresentationController(presentedViewController: presented, presenting: presenting)
   }
}
