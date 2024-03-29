//
//  CustomTicketViewComponents.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//

import UIKit

final class CustomTicketViewComponents<Design: DSP> {
   lazy var bgCover: UIView = {
      let view = UIView()
      view.backgroundColor = .init(white: 0, alpha: 0.6)
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }()
    
   lazy var ticketDetailsView = CustomTicketDetailsView<Design>()
    
   lazy var cancelButton: UIButton = {
      let button = UIButton(type: .custom)
      button.backgroundColor = .gray
      button.layer.cornerRadius = 36 / 2
        
//      button.setImage(UIImage(named: "cancelButton"), for: .normal)
      button.setImage(Design.icon.cancelButton, for: .normal)
        
      NSLayoutConstraint.activate([
         button.heightAnchor.constraint(equalToConstant: 36),
         button.widthAnchor.constraint(equalToConstant: 36),
      ])
        
      button.translatesAutoresizingMaskIntoConstraints = false
      return button
   }()
    
//    MARK: exposed func

   func setupViews(parent: UIView) {
      parent.translatesAutoresizingMaskIntoConstraints = false
        
      parent.addSubview(bgCover)
      parent.addSubview(ticketDetailsView)
      parent.addSubview(cancelButton)
        
      setupConstraints(parent: parent)
   }
    
   func setupLayers(parent: UIView) {}
}

extension CustomTicketViewComponents {
   private func setupConstraints(parent: UIView) {
      NSLayoutConstraint.activate([
         bgCover.topAnchor.constraint(equalTo: parent.topAnchor),
         bgCover.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
         bgCover.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
         bgCover.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
         
         ticketDetailsView.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
         ticketDetailsView.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
         
         cancelButton.topAnchor.constraint(equalTo: ticketDetailsView.bottomAnchor, constant: 30),
         cancelButton.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
      ])
   }
}
