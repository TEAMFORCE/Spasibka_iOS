//
//  IconTitleYVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja
import UIKit

class IconTitleX: StackNinja<SComboMR<ImageViewModel, LabelModel>> {
   var icon: ImageViewModel { models.main }
   var label: LabelModel { models.right }
}

class TitleIconX: StackNinja<SComboMR<LabelModel, ImageViewModel>> {
   var label: LabelModel { models.main }
   var icon: ImageViewModel { models.right }
}

class IconTitleY: StackNinja<SComboMD<ImageViewModel, LabelModel>> {
   var icon: ImageViewModel { models.main }
   var label: LabelModel { models.down }
}

class TitleIconY: StackNinja<SComboMD<LabelModel, ImageViewModel>> {
   var label: LabelModel { models.main }
   var icon: ImageViewModel { models.down }
}
