//
//  SelectWrapper.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.09.2022.
//

class SelectWrapper<T> {
   let value: T
   var isSelected = false
   
   init(value: T) {
      self.value = value
   }

   init(value: T, isSelected: Bool) {
      self.value = value
      self.isSelected = isSelected
   }
}
