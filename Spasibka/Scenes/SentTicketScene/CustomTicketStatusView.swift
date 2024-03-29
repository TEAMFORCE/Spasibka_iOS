//
//  CustomTicketStatusView.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//


import UIKit

final class CustomTicketStatusView<Design: DSP>: UIView {
   enum State: String {
      case notSent = "Не отправлен"
      case inProcess = "Выполняется"
      case canceled = "Отменён"
      case done = "Доставлено"
   }

   var state: State {
      didSet {
         stateLabel.text = state.rawValue
      }
   }

   private lazy var stateLabel: UILabel = {
      let label = UILabel()
      label.text = state.rawValue
      label.font = .systemFont(ofSize: 8)
      label.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1)
        
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()
    

   init(state: State = .notSent) {
      self.state = state
      super.init(frame: .zero)
      setupView()
   }
    
   required init?(coder: NSCoder) {
      self.state = .notSent
      super.init(coder: coder)
   }

   private func setupView() {
      translatesAutoresizingMaskIntoConstraints = false
        
      layer.borderWidth = Constants.borderWidth
      layer.borderColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1).cgColor
      layer.cornerRadius = Constants.corderRadius
        
      addSubview(stateLabel)

      NSLayoutConstraint.activate([
         widthAnchor.constraint(equalToConstant: Constants.viewWidth),
         heightAnchor.constraint(equalToConstant: Constants.viewHeight),
         
         stateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
         stateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      ])
   }
}

extension CustomTicketStatusView {
   enum Constants {
      static var viewHeight: CGFloat { 20 }
      static var viewWidth: CGFloat { 68 }
      static var corderRadius: CGFloat { 8 }
      static var borderWidth: CGFloat { 0.5 }
   }
}
