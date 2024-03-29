//
//  CustomTicketView.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//



import UIKit

final class CustomTicketView<Design: DSP>: UIView {
//    MARK: private properties

   private let viewComponents: CustomTicketViewComponents<Design> = .init()
    
   private var isAnimating: Bool = false
    
//    MARK: lifecycle

   init() {
      super.init(frame: .zero)
      setupView()
      hide(animated: false)
   }
    
   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
    
//    MARK: private func

   private func setupView() {
      viewComponents.setupViews(parent: self)
      viewComponents.cancelButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
   }
   
   @objc func handleCancelButton() {
      hide()
   }
}


extension CustomTicketView {
   func show(animated: Bool = true) {
      guard !isAnimating else { return }
        
      if animated {
         isAnimating = true
            
         alpha = 1
            
         UIView.animateKeyframes(withDuration: 1.2, delay: 0) { [unowned self] in
                
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
               self.viewComponents.bgCover.alpha = 1
            }
                
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) {
               self.viewComponents.ticketDetailsView.alpha = 1
            }
                
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
               self.viewComponents.cancelButton.alpha = 1
            }
                
         } completion: { [unowned self] _ in
            self.isAnimating = false
         }
            
      } else {
         viewComponents.ticketDetailsView.alpha = 1
         viewComponents.cancelButton.alpha = 1
         viewComponents.bgCover.alpha = 1
         alpha = 1
      }
   }
    
   func hide(animated: Bool = true) {
      guard !isAnimating else { return }
        
      if animated {
         isAnimating = true
            
         UIView.animateKeyframes(withDuration: 1.2, delay: 0) { [unowned self] in
                
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
               self.viewComponents.cancelButton.alpha = 0
            }
                
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) {
               self.viewComponents.ticketDetailsView.alpha = 0
            }
                
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
               self.viewComponents.bgCover.alpha = 0
            }
                
         } completion: { [unowned self] _ in
                
            self.alpha = 0
            self.isAnimating = false
         }
            
      } else {
         alpha = 0
         viewComponents.bgCover.alpha = 0
         viewComponents.cancelButton.alpha = 0
         viewComponents.ticketDetailsView.alpha = 0
      }
   }
}

extension CustomTicketView {
   func setDate(date: Date) {
      viewComponents.ticketDetailsView.setDate(date: date)
   }
    
   func setUserInfo(name: String, image: UIImage?, imageUrl: String?, textImage: String) {
      viewComponents.ticketDetailsView.setUserInfo(name: name, image: image, imageUrl: imageUrl, textImage: textImage)
   }
    
   func setCount(_ count: Int) {
      viewComponents.ticketDetailsView.setCount(count)
   }
    
   func setState(_ state: CustomTicketStatusView<Design>.State) {
      viewComponents.ticketDetailsView.setState(state)
   }
}
