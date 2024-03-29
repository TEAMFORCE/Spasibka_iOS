//
//  EditPhotoButton.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.12.2022.
//

import StackNinja

final class EditPhotoButton<Design: DSP>: ButtonModel, Designable {
   override func start() {
      super.start()

      size(.square(Grid.x60.value))
      image(Design.icon.camera)
      backImage(Design.icon.newAvatar)
      contentMode(.scaleAspectFill)
      cornerRadius(Grid.x60.value / 2)
      cornerCurve(.continuous)
   }
}
