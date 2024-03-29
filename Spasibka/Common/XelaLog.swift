//
//  XelaLog.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

import Foundation

func log(_ object: Any, _ slf: Any? = nil) {
   print("\n ##### (\((slf != nil) ? String(describing: slf!) : "")) |-> \(object)\n")
}

func errorLog(_ object: Any, _ slf: Any? = nil) {
   print("\n !!!!! (\((slf != nil) ? String(describing: type(of: slf)) : "")) |-> \(object)\n")
}
