//
//  BottomPopupModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import StackNinja
import UIKit

struct PopupEvent: InitProtocol {
   var hide: Void?
}

enum PopupState {
   case present(model: UIViewModel, onView: UIView?)
   case presentWithAutoHeight(model: UIViewModel, onView: UIView?)
   case presentForTime(model: UIViewModel, onView: UIView?, duration: CGFloat)
   case presentWithAutoHeightForTime(model: UIViewModel, onView: UIView?, duration: CGFloat)
   case hide
}

enum PopupAlign: CGFloat {
   case top = -1
   case bottom = 1
   case center = 0
}

protocol PopupPresenterProtocol: AnyObject {
   var align: PopupAlign { get }
   var darkView: UIView? { get set }
   var presentDuration: CGFloat { get }
}

extension StateMachine where Self: BasePopupPresenter {
   func setState(_ state: PopupState) {
      switch state {
      case let .present(model: model, onView: onView):
         onView?.endEditing(true)

         guard let onView = onView else { return }

         let view = prepareModel(model, onView: onView)
         switch align {
         case .top:
            view.addAnchors.fitToTop(onView)
         case .bottom:
            view.addAnchors.fitToViewInsetted(onView, .init(top: 40, left: 0, bottom: 0, right: 0))
         case .center:
            view.addAnchors
               .centerX(onView.centerXAnchor)
               .centerY(onView.centerYAnchor)
         }

         animateViewAppear(view)
         queue.push(model)
      case let .presentWithAutoHeight(model: model, onView: onView):
         onView?.endEditing(true)

         guard let onView = onView else { return }

         let view = prepareModel(model, onView: onView)

         switch align {
         case .bottom:
            view.addAnchors
               .width(onView.widthAnchor)
               .bottom(onView.bottomAnchor)
         case .top:
            view.addAnchors
               .width(onView.widthAnchor)
               .top(onView.topAnchor)
         case .center:
            view.addAnchors
               .centerX(onView.centerXAnchor)
               .centerY(onView.centerYAnchor)
         }

         animateViewAppear(view)
         queue.push(model)
      case let .presentForTime(model: model, onView: onView, duration: duration):
         onView?.endEditing(true)

         guard let onView = onView else { return }

         let view = prepareModel(model, onView: onView)
         switch align {
         case .top:
            view.addAnchors.fitToTop(onView)
         case .bottom:
            view.addAnchors.fitToViewInsetted(onView, .init(top: 40, left: 0, bottom: 0, right: 0))
         case .center:
            view.addAnchors
               .centerX(onView.centerXAnchor)
               .centerY(onView.centerYAnchor)
         }

         animateViewAppear(view)
         queue.push(model)

         DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.send(\.hide)
         }
      case let .presentWithAutoHeightForTime(model: model, onView: onView, duration: duration):
         onView?.endEditing(true)

         guard let onView = onView else { return }

         let view = prepareModel(model, onView: onView)

         switch align {
         case .bottom:
            view.addAnchors
               .width(onView.widthAnchor)
               .bottom(onView.bottomAnchor)
         case .top:
            view.addAnchors
               .width(onView.widthAnchor)
               .top(onView.topAnchor)
         case .center:
            view.addAnchors
               .centerX(onView.centerXAnchor)
               .centerY(onView.centerYAnchor)
         }

         animateViewAppear(view)
         queue.push(model)

         DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.send(\.hide)
         }
      case .hide:
         hideView()
      }
   }
}

final class BottomPopupPresenter: BasePopupPresenter, StateMachine {
   override var align: PopupAlign { .bottom }
}

final class TopPopupPresenter: BasePopupPresenter, StateMachine {
   override var align: PopupAlign { .top }
}

final class CenterPopupPresenter: BasePopupPresenter, StateMachine {
   override var align: PopupAlign { .center }
}

// BASE

class BasePopupPresenter: BaseModel, PopupPresenterProtocol, Eventable {
   var align: PopupAlign { .bottom }
   var darkView: UIView?

   typealias Events = PopupEvent
   var events = EventsStore()

   let presentDuration: CGFloat = 0.3

   var viewTranslation = CGPoint(x: 0, y: 0)

   lazy var queue: Queue<UIViewModel> = .init()

   override func start() {}

   func prepareModel(_ model: UIViewModel, onView: UIView) -> UIView {
      self.darkView?.removeFromSuperview()

      let view = model.uiView

      let darkView = UIView(frame: onView.frame)
      darkView.backgroundColor = .darkText
      darkView.alpha = 0
      self.darkView = darkView

      onView.addSubview(darkView)
      onView.addSubview(view)
      
      darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDarkView)))
      
      return view
   }

   func animateViewAppear(_ view: UIView) {
      view.layoutIfNeeded()

      let viewHeight: CGFloat
      switch align {
      case .top:
         viewHeight = view.intrinsicContentSize.height
      case .bottom:
         viewHeight = view.intrinsicContentSize.height
      case .center:
         viewHeight = view.intrinsicContentSize.height
      }

      view.transform = CGAffineTransform(translationX: 0, y: viewHeight * align.rawValue)
      UIView.animate(withDuration: presentDuration) {
         view.transform = CGAffineTransform(translationX: 0, y: 0)
         self.darkView?.alpha = 0.5
      }

      let tapGest = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
      tapGest.cancelsTouchesInView = false

      view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
      view.addGestureRecognizer(tapGest)
   }

   @objc private func didTapOnView(sender: UITapGestureRecognizer) {
      sender.view?.endEditing(true)
   }
   
   @objc private func didTapDarkView() {
      hideView()
   }

   @objc func handleDismiss(sender: UIPanGestureRecognizer) {
      guard let view = sender.view else { return }

      switch sender.state {
      case .changed:
         viewTranslation = sender.translation(in: view)
         switch align {
         case .bottom:
            UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               view.transform = CGAffineTransform(
                  translationX: 0,
                  y: self.viewTranslation.y > 0 ? self.viewTranslation.y : 0
               )
            })
         case .top:
            UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               view.transform = CGAffineTransform(
                  translationX: 0,
                  y: self.viewTranslation.y < 0 ? self.viewTranslation.y : 0
               )
            })
         case .center:
            UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               view.transform = CGAffineTransform(
                  translationX: 0,
                  y: self.viewTranslation.y
               )
            })
         }

      case .ended, .cancelled, .failed:
         viewTranslation = sender.translation(in: view)
         switch align {
         case .bottom:

            if viewTranslation.y < 200 {
               UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                  view.transform = .identity
               })
            } else {
               hideView()
            }
         case .top:
            if viewTranslation.y > 200 {
               UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                  view.transform = .identity
               })
            } else {
               hideView()
            }
         case .center:
            if viewTranslation.y < 150 && viewTranslation.y > -150  {
               UIView.animate(withDuration: presentDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                  view.transform = .identity
               })
            } else {
               hideView()
            }
         }
      default:
         break
      }
   }

   func hideAll(animated: Bool) {
      while let view = queue.pop()?.uiView {
         if animated {
            UIView.animate(withDuration: 0.23) {
               if self.queue.isEmpty {
                  self.darkView?.alpha = 0
               }
               view.transform = CGAffineTransform(translationX: 0, y: view.frame.height * self.align.rawValue)
            } completion: { _ in
               view.removeFromSuperview()
               view.transform = .identity

               if self.queue.isEmpty {
                  self.darkView?.removeFromSuperview()
                  self.darkView = nil
               }
            }
         } else {
            view.removeFromSuperview()
            view.transform = .identity
            darkView?.removeFromSuperview()
            darkView = nil
         }
      }

      send(\.hide)
   }

   func hideView() {
      send(\.hide)
      
      guard let view = queue.pop()?.uiView else {
         return
      }

      UIView.animate(withDuration: 0.23) {
         if self.queue.isEmpty {
            self.darkView?.alpha = 0
         }
         view.transform = CGAffineTransform(translationX: 0, y: view.frame.height * self.align.rawValue)
      } completion: { _ in
         view.removeFromSuperview()
         view.transform = .identity
         
         if self.queue.isEmpty {
            self.darkView?.removeFromSuperview()
            self.darkView = nil
         }
      }
   }
}
