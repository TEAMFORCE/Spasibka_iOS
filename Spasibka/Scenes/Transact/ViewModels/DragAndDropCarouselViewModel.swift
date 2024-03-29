//
//  DragAndDropCarouselViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.10.2023.
//

import StackNinja
import UIKit

final class DragAndDropCarouselViewModel<Design: DSP>: ScrollStackedModelX, Designable, Eventable2 {
   struct Events2: InitProtocol {
      var didDeleteViewModelAtIndex: Int?
      var didMoveViewModel: (from: Int, to: Int)?
   }

   var events2 = EventsStore()

   private var isAnimating = false

   private let superView: UIView?
   private lazy var draggingSubviewCopy = UIImageView()
   private var stackSubView: UIView?
   private lazy var emptyView = UIImageView()

   private var homeIndex: Int?
   private var newIndex: Int?

   init(superView: UIView?) {
      self.superView = superView

      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   override func start() {
      super.start()
      stack.spacing(8)

      view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:))))
   }

   func addViewModel(_ viewModel: CarouselCellProtocol) {
   //   viewModels.append(viewModel)
      addArrangedModels(viewModel)
      weak var uiView = viewModel.uiView
      viewModel.closeButton.on(\.didTap, self) {
         guard let uiView else { return }
         guard let index = self.getIndexForView(uiView) else { return }
         
         uiView.removeFromSuperview()
    //     $0.viewModels.remove(at: index)
         $0.send(\.didDeleteViewModelAtIndex, index)
      }
   }

   @objc func handleTap(_ sender: UIPanGestureRecognizer) {
      let location = sender.location(in: view)

      switch sender.state {
      case .possible:
         break
      case .began:
         guard let handledView = stack.view.arrangedSubviews
            .first(where: { uiView in
               uiView.frame.contains(location)
            })
         else { return }

         stackSubView = handledView
         let index = getIndexForView(handledView) ?? 0
         homeIndex = index
         let image = handledView.renderToImage()
         draggingSubviewCopy.image = image
         draggingSubviewCopy.frame.size = handledView.frame.size
         emptyView.addAnchors
            .constWidth(handledView.frame.width)
            .constHeight(handledView.frame.height)
         let newCenter = sender.location(in: superView) 
         superView?.addSubview(draggingSubviewCopy)
         draggingSubviewCopy.center = newCenter
         stack.view.insertArrangedSubview(emptyView, at: index)
         handledView.removeFromSuperview()

      case .changed:
         let newCenter = sender.location(in: superView)
         draggingSubviewCopy.center = newCenter
         insertEmptyViewIfNeededTo(position: checkThatDraggingViewIsBeetwenTwoOthers())
      case .cancelled, .failed:
         emptyView.removeFromSuperview()
         if let homeIndex = homeIndex, let stackSubView {
            stack.view.insertArrangedSubview(stackSubView, at: homeIndex)
         }

         homeIndex = nil
         newIndex = nil
         draggingSubviewCopy.removeFromSuperview()

      case .ended:

         emptyView.removeFromSuperview()
         draggingSubviewCopy.removeFromSuperview()
         if let homeIndex, let newIndex = newIndex, let stackSubView {
            send(\.didMoveViewModel, (homeIndex, newIndex))
            stack.view.insertArrangedSubview(stackSubView, at: newIndex)
         }

         homeIndex = nil
         newIndex = nil

      @unknown default:
         break
      }
   }

   private func insertEmptyViewIfNeededTo(position: Int?) {
      if let position, position != newIndex {
         newIndex = position
         emptyView.removeFromSuperview()
         stack.view.insertArrangedSubview(emptyView, at: position)
      }
   }

   private func checkThatDraggingViewIsBeetwenTwoOthers() -> Int? {
      guard let superView = superView else { return nil }

      let distanceThresh: CGFloat = 20
      let draggingView = draggingSubviewCopy
      let draggingViewCenter = draggingView.center

      for (index, uiView) in stack.view.arrangedSubviews.enumerated() {
         let boundsCenterX = uiView.bounds.minX + uiView.frame.width / 2
         let boundsCenterY = uiView.bounds.minY + uiView.frame.height / 2
         let boundsCenter = CGPoint(x: boundsCenterX, y: boundsCenterY)
         let center = uiView.convert(boundsCenter, to: superView)
         let centerX = center.x

         let diff = abs(centerX - draggingViewCenter.x)
         if diff < distanceThresh {
            return index
         }
      }

      return nil
   }

   private func getIndexForView(_ view: UIView) -> Int? {
      let hashValue = view.hashValue
      return stack.view.arrangedSubviews.firstIndex(where: { $0.hashValue == hashValue })
   }

   func clear() {
      arrangedModels([])
   }
}

extension UIView {
   func renderToImage() -> UIImage {
      UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
      drawHierarchy(in: bounds, afterScreenUpdates: false)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image!
   }
}
