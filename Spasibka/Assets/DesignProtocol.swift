//
//  DesignSystemProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.06.2022.
//

import StackNinja

/*

 ...
 Design.label
 Design.icon
 Design.button
 Design.text
 Design.font
 Design.params

 Design.state.label
 Design.state.button
 Design.state.stack
 Design.state.view
 ...

  */

typealias DSP = DesignProtocol

protocol DesignProtocol: DesignRoot where
   Text: TextsProtocol,
   Color: ColorsProtocol,
   Icon: IconElements,
   Font: FontProtocol,
   Label: LabelProtocol,
   Button: ButtonBuilderProtocol,
   State: StateProtocol,
   Params: ParamsProtocol,
   Model: ModelBuilderProtocol
{
   static var text: Text { get }
   static var model: Model { get }
}

extension DesignProtocol {
   static var text: Text { .init() }
   static var model: Model { .init() }
}

protocol ModelBuilderProtocol: InitProtocol, Designable {
   associatedtype Transact: TransactModelBuilder
   associatedtype Profile: ProfileModelBuilder
   associatedtype Common: CommonModelBuilder
   associatedtype Presenter: PresenterModelBuilder
}

extension ModelBuilderProtocol {
   var transact: Transact { .init() }
   var profile: Profile { .init() }
   var common: Common { .init() }
   var presenter: Presenter { .init() }
}
