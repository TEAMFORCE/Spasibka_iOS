//
//  DesignSystem.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.06.2022.
//

import StackNinja
import UIKit

struct DesignSystem: DesignProtocol {
   typealias Text = Texts
   typealias Icon = IconBuilder
   typealias Color = ColorBuilder
   typealias Font = FontBuilder
   typealias Label = LabelBuilder<Self>
   typealias Button = ButtonBuilder<Self>

   typealias Params = ParamBuilder<Self>
   typealias State = StateBuilders<Self>

   typealias Model = ModelBuilder<Self>
}

struct StateBuilders<Design: DesignProtocol>: StateProtocol {
   typealias Stack = StackStateBuilder<Design>
   typealias Label = LabelStateBuilder<Design>
   typealias Button = ButtonStateBuilder<Design>
   typealias TextField = TextFieldStateBuilder<Design>
}
