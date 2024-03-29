//
//  UserStatus.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2022.
//

import Foundation
import StackNinja

enum UserStatus: String, CaseIterable {
   case office = "O"
   case remote = "D"
   case vacation = "H"
   case sickLeave = "S"
   case working = ""

//   func text() -> String {
//      switch self {
//      case .office:
//         return "В офисе" //Design.text.inOfficeStatus
//      case .remote:
//         return "Удаленно" // Design.text.remoteStatus
//      case .vacation:
//         return "В отпуске" //Design.text.vactionStatus
//      case .sickLeave:
//         return "На больничном" //Design.text.sickLeaveStatus
//      case .working:
//         return "Работает"
//      }
//   }
}
