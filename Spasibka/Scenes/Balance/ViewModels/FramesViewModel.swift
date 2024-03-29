//
//  FramesViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 05.12.2023.
//

import StackNinja
import UIKit

final class FramesViewModel<Design: DesignProtocol>: UIViewModel, Stateable {
   public typealias State = ViewState
   
   var uiView: UIView
   
   var isAutoreleaseView: Bool
   
   init(){
      self.uiView = .init()
      self.isAutoreleaseView = false
   }
   
   private var cardHeight: CGFloat = 245
   private var cardWidth: CGFloat = 206
//   let brandSecondaryColor = UIColor(red: 1, green: 0.941, blue: 0.851, alpha: 1)
   private lazy var myAccountFrame = FrameCellModelDT<Design>(color: Design.color.backgroundBrandSecondary)
      .set(.header(Design.text.myAccount))
      .set(.height(cardHeight))
      .set(.textColor(Design.color.text))
   
   private lazy var leftToSendFrame = FrameCellModelDT<Design>(color: Design.color.iconBrand)
      .set(.header(Design.text.leftToSend))
      .set(.height(cardHeight))
      .set(.hideBackImage(true))
   
   private var isLeftOnTop: Bool = true
   private var isAnimating: Bool = false
   
   func start() {
      myAccountFrame.uiView.translatesAutoresizingMaskIntoConstraints = false
      leftToSendFrame.uiView.translatesAutoresizingMaskIntoConstraints = false
      uiView.addSubview(myAccountFrame.uiView)
      uiView.addSubview(leftToSendFrame.uiView)
      configureConstraints()
      swapCards(isSetup: true)
   }
   
   func configureConstraints() {
      NSLayoutConstraint.activate([
         uiView.heightAnchor.constraint(equalToConstant: cardHeight),
         uiView.widthAnchor.constraint(equalToConstant: 412),
         myAccountFrame.uiView.heightAnchor.constraint(equalToConstant: cardHeight),
         myAccountFrame.uiView.widthAnchor.constraint(equalToConstant: cardWidth),
         myAccountFrame.uiView.topAnchor.constraint(equalTo: uiView.safeAreaLayoutGuide.topAnchor, constant: .zero),
         myAccountFrame.uiView.leadingAnchor.constraint(equalTo: uiView.safeAreaLayoutGuide.leadingAnchor, constant: .zero),
         
         leftToSendFrame.uiView.heightAnchor.constraint(equalToConstant: cardHeight),
         leftToSendFrame.uiView.widthAnchor.constraint(equalToConstant: cardWidth),
         leftToSendFrame.uiView.topAnchor.constraint(equalTo: uiView.safeAreaLayoutGuide.topAnchor, constant: .zero),
         leftToSendFrame.uiView.trailingAnchor.constraint(equalTo: uiView.safeAreaLayoutGuide.trailingAnchor, constant: .zero),
         
      ])
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSwap))
      let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleSwap))
      
      leftToSendFrame.uiView.addGestureRecognizer(tapGesture)
      myAccountFrame.uiView.addGestureRecognizer(tapGesture1)
      
   }
   
   @objc func handleSwap() {
      swapCards()
   }
   
   private func swapCards(isSetup: Bool = false) {
      guard !isAnimating else { return }
      isAnimating = true
      
      if isSetup {
         isLeftOnTop = true
      } else {
         isLeftOnTop.toggle()
      }
      
      animateSwap(isSetup: isSetup)
   }
   
   private func animateSwap(isSetup: Bool) {
      let swapCardsClosure = { [unowned self] in
         
         if self.isLeftOnTop {
            self.myAccountFrame.uiView.layer.zPosition = 10
            self.leftToSendFrame.uiView.layer.zPosition = 5
            
            self.myAccountFrame.uiView.transform = .identity
            self.leftToSendFrame.uiView.transform = .init(scaleX: 0.9, y: 0.9)
            
         } else {
            self.myAccountFrame.uiView.layer.zPosition = 5
            self.leftToSendFrame.uiView.layer.zPosition = 10
            
            self.myAccountFrame.uiView.transform = .init(scaleX: 0.9, y: 0.9)
            self.leftToSendFrame.uiView.transform = .identity
         }
         
      }
      
      if isSetup {
         swapCardsClosure()
      } else {
         UIView.animate(withDuration: 0.6, animations: swapCardsClosure)
      }
      isAnimating = false
      
   }
}

enum FramesViewModelState {
   case setBalance(Balance)
}
extension FramesViewModel: StateMachine {
   func setState(_ state: FramesViewModelState) {
      switch state {
      case let .setBalance(balance):
         setBalance(balance)
      }
   }
}

extension FramesViewModel {
   private func setBalance(_ balance: Balance) {
      setIncome(balance.income)
      setDistr(balance.distr)
      
      let frozenSum = balance.income.frozen
      let cancelledSum = balance.income.cancelled + balance.distr.cancelled
   }
   
   private func setIncome(_ income: Income) {
      myAccountFrame
         .set(.text(String(income.amount)))
         .set(.caption("\(Design.text.canceled) \(income.cancelled)"))
         .set(.hideBurnLabel)
   }
   
   private func setDistr(_ distr: Distr) {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      var diffs = 0
      if let date1 = dateFormatter.date(from: distr.expireDate.unwrap) {
         let date2 = Date()
         diffs = Calendar.current.numberOf24DaysBetween(date2, and: date1)
      }
      
      leftToSendFrame
         .set(.text(String(distr.amount)))
         .set(.caption("\(Design.text.onAgreement) \(distr.frozen)"))
         .set(.burn(title: "\(Design.text.remainingDayText)\(diffs) \(getDeclension(abs(diffs)))"))
//         .set(.burn(title: "\(diffs)",
//                    body: "\(getDeclension(abs(diffs))) \(Design.text.toTheEndPeriodSuffix)"))
   }
   
   private func getDeclension(_ day: Int) -> String {
      let preLastDigit = day % 100 / 10
      if preLastDigit == 1 {
         return Design.text.days
      } else {
         switch day % 10 {
         case 1:
            return Design.text.day
         case 2, 3, 4:
            return Design.text.days1
         default:
            return Design.text.days
         }
      }
   }
}
