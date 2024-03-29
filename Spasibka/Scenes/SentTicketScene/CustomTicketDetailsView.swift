//
//  CustomTicketDetailsView.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//

import UIKit

final class CustomTicketDetailsView<Design: DSP>: UIView {
   private let viewComponents: CustomTicketDetailsViewComponents<Design> = .init()
    
   private let dateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd.MM.yyyy"
      return dateFormatter
   }()
    
   private let timeFormatter: DateFormatter = {
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "HH:mm"
      return timeFormatter
   }()
    
//    MARK: lifecycle

   init() {
      super.init(frame: .zero)
      setupView()
   }
    
   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
    
   override func layoutSubviews() {
      super.layoutSubviews()
      setupLayer()
   }
    
//    MARK: private func

   private func setupView() {
      viewComponents.setupView(parent: self)
   }
    
   private func setupLayer() {
      viewComponents.setupLayer(parent: self)
   }
}

extension CustomTicketDetailsView {
   enum Constants {
      static var cornerRadius: CGFloat { 16 }
        
      static var viewWidth: CGFloat { 220 }
      static var viewHeight: CGFloat { 380 }
   }
}

extension CustomTicketDetailsView {
   func setDate(date: Date) {
      viewComponents.dateLabel.text = dateFormatter.string(from: date)
      viewComponents.timeLabel.text = timeFormatter.string(from: date)
   }
    
   func setUserInfo(name: String, image: UIImage?, imageUrl: String?, textImage: String) {
      viewComponents.usernameLabel.text = name
      if let imageUrl = imageUrl {
         viewComponents.avatarImageView.url(imageUrl)
         viewComponents.avatarImageView.view.alpha = 1
      } else if let image = image {
         viewComponents.avatarImageView.view.alpha = 1
         viewComponents.avatarImageView.image(image)
      } else if textImage.isEmpty == false {
         let image = textImage.drawImage(backColor: Design.color.backgroundBrand)
         viewComponents.avatarImageView
            .backColor(Design.color.backgroundBrand)
            .image(image)
         
      } else {
         viewComponents.avatarImageView.image(Design.icon.avatarPlaceholder)
                  viewComponents.avatarImageView.view.alpha = 1
      }
   }
    
   func setCount(_ count: Int) {
      switch count {
      case Int.min ..< 0:
         viewComponents.countLabel.text = "X"
            
      default:
         viewComponents.countLabel.text = Design.text.pluralCurrencyWithValue(count, case: .genitive)
      }
   }
    
   func setState(_ state: CustomTicketStatusView<Design>.State) {
      viewComponents.stateView.state = state
   }
}
