//
//  CustomTicketDetailsViewComponents.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//


import UIKit
import StackNinja

final class CustomTicketDetailsViewComponents<Design: DSP> {
   lazy var thanksLabel: UILabel = getLabel(defaultText: Design.text.thanks, type: .thanks)
   lazy var infomationalLabel = getLabel(defaultText: Design.text.transactStatusLabel, type: .aboutRequestInfo)
    
   lazy var datePointerLabel = getLabel(defaultText: Design.text.date, type: .pointer)
   lazy var timePointerLabel = getLabel(defaultText: Design.text.time, type: .pointer)
   lazy var usernamePointerLabel = getLabel(defaultText: Design.text.toWhom, type: .pointer)
   lazy var countPointerLabel = getLabel(defaultText: Design.text.amount, type: .pointer)
    
   lazy var dateLabel = getLabel(defaultText: "11.33.1123", type: .body)
   lazy var timeLabel = getLabel(defaultText: "12:54", type: .body)
   lazy var usernameLabel = getLabel(defaultText: "Cyborg Genos", type: .body)
   lazy var countLabel = getLabel(defaultText: "1 спасибка", type: .body)
    
   lazy var separatorView: UIView = {
      let view = UIView()
        
      view.backgroundColor = .clear
      view.translatesAutoresizingMaskIntoConstraints = false
        
      NSLayoutConstraint.activate([
         view.widthAnchor.constraint(equalToConstant: Constants.viewWidth - Constants.paddingL),
         view.heightAnchor.constraint(equalToConstant: 1),
      ])
        
      let caShapeLayer = CAShapeLayer()
      caShapeLayer.strokeColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1).cgColor
      caShapeLayer.lineWidth = 1
      caShapeLayer.lineDashPattern = [10, 10]
        
      let cgPath = CGMutablePath()
      let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: Constants.viewWidth - Constants.paddingL, y: 0)]
        
      cgPath.addLines(between: cgPoint)
      caShapeLayer.path = cgPath
        
      view.layer.addSublayer(caShapeLayer)
      return view
   }()
    
   lazy var avatarImageView = getImage(type: .avatar)
   lazy var heartIconView = getImage(type: .heartIcon)
    
   lazy var stateView = CustomTicketStatusView<Design>()
    
//    MARK: func

   func setupView(parent: UIView) {
      parent.translatesAutoresizingMaskIntoConstraints = false
      parent.clipsToBounds = false
        
      parent.backgroundColor = UIColor(red: 234 / 255, green: 234 / 255, blue: 234 / 255, alpha: 1)
      parent.layer.cornerRadius = Constants.cornerRadius
        
      parent.addSubview(heartIconView.uiView)
        
      parent.addSubview(thanksLabel)
      parent.addSubview(infomationalLabel)
        
      parent.addSubview(separatorView)
        
      parent.addSubview(datePointerLabel)
      parent.addSubview(dateLabel)
      parent.addSubview(timePointerLabel)
      parent.addSubview(timeLabel)
      parent.addSubview(usernamePointerLabel)
      parent.addSubview(avatarImageView.uiView)
      parent.addSubview(usernameLabel)
      parent.addSubview(countPointerLabel)
      parent.addSubview(countLabel)
      parent.addSubview(stateView)
        
      setupConstraints(parent: parent)
   }
    
   func setupLayer(parent: UIView) {
      setSideHolesMask(parent: parent)
   }
}

extension CustomTicketDetailsViewComponents {
   enum Constants {
      static var paddingS: CGFloat { 6 }
      static var paddingM: CGFloat { 16 }
      static var paddingMM: CGFloat { 25 }
      static var paddingL: CGFloat { 30 }
        
      static var cornerRadius: CGFloat { 16 }
        
      static var viewWidth: CGFloat { 243 }
      static var viewHeight: CGFloat { 349 }
        
      static var avatarViewDimension: CGFloat { 32 }
      static var heartIconViewDimension: CGFloat { 48 }
        
      static var sideHolesDimension: CGFloat { 20 }
      static var sideHolesSize: CGSize { .init(width: sideHolesDimension, height: sideHolesDimension) }
        
      static var sideHolesYPosition: CGFloat { 90 }
      static var leftHoleOrigin: CGPoint { .init(x: -sideHolesDimension / 2, y: sideHolesYPosition) }
      static var rightHoleOrigin: CGPoint { .init(x: viewWidth - sideHolesDimension / 2, y: sideHolesYPosition) }
        
      static var heartCircleOrigin: CGPoint { .init(x: (viewWidth - heartIconViewDimension) / 2, y: heartIconViewDimension / 2) }
      static var heartCircleSize: CGSize { .init(width: heartIconViewDimension, height: heartIconViewDimension) }
   }
}

extension CustomTicketDetailsViewComponents {
   private func setSideHolesMask(parent: UIView) {
      let maskLayer = CAShapeLayer()
      let path = CGMutablePath()
        
      let leftHoleMaskRect = CGRect(origin: Constants.leftHoleOrigin, size: Constants.sideHolesSize)
      let rightHoleMaskRect = CGRect(origin: Constants.rightHoleOrigin, size: Constants.sideHolesSize)
        
      path.addPath(UIBezierPath(rect: parent.bounds).cgPath)
        
      path.addPath(UIBezierPath(roundedRect: leftHoleMaskRect, cornerRadius: Constants.sideHolesDimension / 2).cgPath)
      path.addPath(UIBezierPath(roundedRect: rightHoleMaskRect, cornerRadius: Constants.sideHolesDimension / 2).cgPath)
        
      // Create a UIBezierPath for the half arc
      let arcPath = UIBezierPath(
         arcCenter: CGPoint(x: Constants.viewWidth / 2, y: 0),
         radius: Constants.heartIconViewDimension,
         startAngle: CGFloat.pi,
         endAngle: 0,
         clockwise: true
      )
      path.addPath(arcPath.cgPath)
        
      maskLayer.path = path
        
      maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
      parent.layer.mask = maskLayer
   }
}

extension CustomTicketDetailsViewComponents {
   private enum LabelType {
      case thanks
      case aboutRequestInfo
      case pointer
      case body
   }
    
   private enum ImageType {
      case heartIcon
      case avatar
   }
    
   private func getLabel(defaultText: String, type: LabelType) -> UILabel {
      let label = UILabel()
      label.textColor = .black
        
      switch type {
      case .body:
         label.font = .systemFont(ofSize: 12)
            
      case .thanks:
         label.font = .systemFont(ofSize: 20)
            
      case .aboutRequestInfo, .pointer:
         label.font = .systemFont(ofSize: 12, weight: .light)
      }
        
      label.text = defaultText
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }
    
   private func getImage(type: ImageType) -> ImageViewModel {
//      let view = UIImageView()
//      view.contentMode = .scaleAspectFill
      let newView = ImageViewModel()
      newView.contentMode(.scaleAspectFill)
      
        
      switch type {
      case .heartIcon:
         NSLayoutConstraint.activate([
            newView.view.widthAnchor.constraint(equalToConstant: Constants.heartIconViewDimension),
            newView.view.heightAnchor.constraint(equalToConstant: Constants.heartIconViewDimension),
         ])
         newView.image(Design.icon.ticketHeartIcon )
         newView.view.backgroundColor = .systemOrange
         newView.view.layer.cornerRadius = Constants.heartIconViewDimension / 2
            
      case .avatar:
         NSLayoutConstraint.activate([
            newView.view.widthAnchor.constraint(equalToConstant: Constants.avatarViewDimension),
            newView.view.heightAnchor.constraint(equalToConstant: Constants.avatarViewDimension),
         ])
         newView.view.backgroundColor = .systemBlue
         newView.view.layer.cornerRadius = Constants.avatarViewDimension / 2
      }
        
      newView.view.translatesAutoresizingMaskIntoConstraints = false
      return newView
   }
}

extension CustomTicketDetailsViewComponents {
   private func setupConstraints(parent: UIView) {
      NSLayoutConstraint.activate([
         parent.widthAnchor.constraint(equalToConstant: Constants.viewWidth),
         parent.heightAnchor.constraint(equalToConstant: Constants.viewHeight),
         
         heartIconView.view.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
         heartIconView.view.centerYAnchor.constraint(equalTo: parent.topAnchor),
         
         thanksLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
         thanksLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: Constants.paddingMM),
         
         infomationalLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
         infomationalLabel.topAnchor.constraint(equalTo: thanksLabel.bottomAnchor, constant: Constants.paddingS),
         
         separatorView.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
         separatorView.centerYAnchor.constraint(equalTo: parent.topAnchor, constant: Constants.sideHolesYPosition + Constants.sideHolesDimension / 2),
         
         datePointerLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Constants.paddingL + Constants.paddingS),
         datePointerLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         dateLabel.topAnchor.constraint(equalTo: datePointerLabel.bottomAnchor, constant: Constants.paddingS),
         dateLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         timePointerLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Constants.paddingL + Constants.paddingS),
         timePointerLabel.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -Constants.paddingL),
         
         timeLabel.topAnchor.constraint(equalTo: timePointerLabel.bottomAnchor, constant: Constants.paddingS),
         timeLabel.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -Constants.paddingL),
         
         usernamePointerLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.paddingL),
         usernamePointerLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         avatarImageView.view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -Constants.paddingL),
         avatarImageView.view.centerYAnchor.constraint(equalTo: usernamePointerLabel.centerYAnchor, constant: Constants.avatarViewDimension / 2),
         
         usernameLabel.topAnchor.constraint(equalTo: usernamePointerLabel.bottomAnchor, constant: Constants.paddingS),
         usernameLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         countPointerLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.paddingL),
         countPointerLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         countLabel.topAnchor.constraint(equalTo: countPointerLabel.bottomAnchor, constant: Constants.paddingS),
         countLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: Constants.paddingL),
         
         stateView.centerYAnchor.constraint(equalTo: countPointerLabel.centerYAnchor, constant: CustomTicketStatusView<Design>.Constants.viewHeight / 2),
         stateView.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -Constants.paddingL),
      ])
   }
}
