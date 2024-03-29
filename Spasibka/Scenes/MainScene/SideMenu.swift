//
//  SideMenu.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.01.2023.
//

import StackNinja

struct SideMenuEvents: InitProtocol {
   // top part
   var didSelectMarketplace: Void?
   var didSelectHistory: Void?
   var didSelectAnalytics: Void?
   var didSelectEmployees: Void?
   var didSelectAwards: Void?

   // bottom part
   var didSelectSettings: Void?
}

final class SideMenu<Design: DSP>: StackModel, Designable, Eventable {
   typealias Events = SideMenuEvents
   var events: EventsStore = .init()
   
   private(set) lazy var logoModel = MenuLogo<Design>()
      .height(64)
   
   // top part
   private lazy var menuMarketplace = menuLabel(text: Design.text.benefitCafe)
      .on(\.didTap, self) { $0.send(\.didSelectMarketplace) }
   private lazy var menuHistory = menuLabel(text: Design.text.history)
      .on(\.didTap, self) { $0.send(\.didSelectHistory) }
   private lazy var menuAnalytics = menuLabel(text: Design.text.analytics)
      .on(\.didTap, self) { $0.send(\.didSelectAnalytics) }
   private lazy var menuEmployees = menuLabel(text: Design.text.participants)
      .on(\.didTap, self) { $0.send(\.didSelectEmployees) }
   private lazy var menuAwards = menuLabel(text: Design.text.awards)
      .on(\.didTap, self) { $0.send(\.didSelectAwards) }

   // bottom part
   private lazy var menuSettings = menuLabel(text: Design.text.settings)
      .on(\.didTap, self) { $0.send(\.didSelectSettings) }
   
   override func start() {
      if Config.appConfig == .production {
         menuAnalytics.hidden(true)
      }
      
      alignment(.leading)
      backColor(Design.color.backgroundBrand)
      padding(.init(top: 0, left: 24, bottom: 0, right: 0))
      arrangedModels(
         logoModel,
         Spacer(32),
         menuMarketplace,
         menuHistory,
         menuAnalytics.hidden(true),
         menuEmployees,
         menuAwards,
         Spacer(),
         menuSettings,
         Spacer(48)
      )
   }
   
   private func menuLabel(text: String) -> LabelModel {
      let textColor
      = Design.color.backgroundBrand.brightnessStyle(brightnessTreshold: 0.6) == .dark
      ? Design.color.constantWhite
      : Design.color.constantBlack
      
      return LabelModel()
         .set(Design.state.label.medium16)
         .text(text)
         .textColor(textColor)
         .height(60)
         .makeTappable()
   }
}
