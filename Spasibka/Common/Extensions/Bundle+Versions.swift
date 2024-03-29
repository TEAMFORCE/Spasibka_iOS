//
//  Bundle+Versions.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.12.2022.
//

import Foundation

extension Bundle {
   var releaseVersionNumber: String? {
      infoDictionary?["CFBundleShortVersionString"] as? String
   }

   var buildVersionNumber: String? {
      infoDictionary?["CFBundleVersion"] as? String
   }
}
