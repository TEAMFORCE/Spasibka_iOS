//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.10.2022.
//

import StackNinja

// MARK: - Many Button events

protocol ManyButtonEvent: RawRepresentable where RawValue == Int {}

enum Button1Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
}

enum Button2Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
}

enum Button3Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
   case didTapButton3 = 2
}

enum Button4Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
   case didTapButton3 = 2
   case didTapButton4 = 3
}

enum Button5Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
   case didTapButton3 = 2
   case didTapButton4 = 3
   case didTapButton5 = 4
}

enum Button6Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
   case didTapButton3 = 2
   case didTapButton4 = 3
   case didTapButton5 = 4
   case didTapButton6 = 5
}

enum Button7Event: Int, ManyButtonEvent {
   case didTapButton1 = 0
   case didTapButton2 = 1
   case didTapButton3 = 2
   case didTapButton4 = 3
   case didTapButton5 = 4
   case didTapButton6 = 5
   case didTapButton7 = 6
}

protocol IndexedButtonsProtocol: Eventable where Events == ManyButtonsTapEvent<ButtEvents> {
//   associatedtype Button: ModableButtonModelProtocol
   associatedtype ButtEvents: ManyButtonEvent

   var buttons: [any ModableButtonModelProtocol] { get }

   init(buttons: any ModableButtonModelProtocol...)
}

import UIKit

extension IndexedButtonsProtocol {
   init(_ but1: any ModableButtonModelProtocol) where Self.ButtEvents == Button1Event {
      self.init(buttons: but1)
   }

   init(_ but1: any  ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol) where Self.ButtEvents == Button2Event
   {
      self.init(buttons: but1, but2)
   }

   init(_ but1: any ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol,
        _ but3: any ModableButtonModelProtocol) where Self.ButtEvents == Button3Event
   {
      self.init(buttons: but1, but2, but3)
   }

   init(_ but1: any ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol,
        _ but3: any ModableButtonModelProtocol,
        _ but4: any ModableButtonModelProtocol) where Self.ButtEvents == Button4Event
   {
      self.init(buttons: but1, but2, but3, but4)
   }

   init(_ but1: any ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol,
        _ but3: any ModableButtonModelProtocol,
        _ but4: any ModableButtonModelProtocol,
        _ but5: any ModableButtonModelProtocol) where Self.ButtEvents == Button5Event
   {
      self.init(buttons: but1, but2, but3, but4, but5)
   }

   init(_ but1: any ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol,
        _ but3: any ModableButtonModelProtocol,
        _ but4: any ModableButtonModelProtocol,
        _ but5: any ModableButtonModelProtocol,
        _ but6: any ModableButtonModelProtocol) where Self.ButtEvents == Button5Event
   {
      self.init(buttons: but1, but2, but3, but4, but5, but6)
   }
   
   init(_ but1: any ModableButtonModelProtocol,
        _ but2: any ModableButtonModelProtocol,
        _ but3: any ModableButtonModelProtocol,
        _ but4: any ModableButtonModelProtocol,
        _ but5: any ModableButtonModelProtocol,
        _ but6: any ModableButtonModelProtocol,
        _ but7: any ModableButtonModelProtocol) where Self.ButtEvents == Button5Event
   {
      self.init(buttons: but1, but2, but3, but4, but5, but6, but7)
   }
}

extension IndexedButtonsProtocol where ButtEvents == Button1Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
}

extension IndexedButtonsProtocol where ButtEvents == Button2Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
}

extension IndexedButtonsProtocol where ButtEvents == Button3Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
   var button3: any ModableButtonModelProtocol { buttons[2] }
}

extension IndexedButtonsProtocol where ButtEvents == Button4Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
   var button3: any ModableButtonModelProtocol { buttons[2] }
   var button4: any ModableButtonModelProtocol { buttons[3] }
}

extension IndexedButtonsProtocol where ButtEvents == Button5Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
   var button3: any ModableButtonModelProtocol { buttons[2] }
   var button4: any ModableButtonModelProtocol { buttons[3] }
   var button5: any ModableButtonModelProtocol { buttons[4] }
}

extension IndexedButtonsProtocol where ButtEvents == Button6Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
   var button3: any ModableButtonModelProtocol { buttons[2] }
   var button4: any ModableButtonModelProtocol { buttons[3] }
   var button5: any ModableButtonModelProtocol { buttons[4] }
   var button6: any ModableButtonModelProtocol { buttons[5] }
}

extension IndexedButtonsProtocol where ButtEvents == Button7Event {
   var button1: any ModableButtonModelProtocol { buttons[0] }
   var button2: any ModableButtonModelProtocol { buttons[1] }
   var button3: any ModableButtonModelProtocol { buttons[2] }
   var button4: any ModableButtonModelProtocol { buttons[3] }
   var button5: any ModableButtonModelProtocol { buttons[4] }
   var button6: any ModableButtonModelProtocol { buttons[5] }
   var button7: any ModableButtonModelProtocol { buttons[6] }
}
