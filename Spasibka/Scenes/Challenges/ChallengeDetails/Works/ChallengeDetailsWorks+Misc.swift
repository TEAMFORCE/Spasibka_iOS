//
//  ChallengeDetailsWorks+Misc.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.11.2022.
//

import StackNinja

extension ChallengeDetailsWorks {
   var anyReportToPresent: MapOut<Int> { .init {
      guard
         let reportId = Self.store.reportId
      else {
         return nil
      }
      Self.store.reportId = nil
      return reportId
   } }
   
   var getLinkToShare: MapOut<String> { .init {
      guard let linkToShare = Self.store.challenge?.linkToShare else { return nil }
      return linkToShare
   } }
}
