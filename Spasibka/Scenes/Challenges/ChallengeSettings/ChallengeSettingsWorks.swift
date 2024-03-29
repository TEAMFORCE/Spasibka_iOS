//
//  ChallengeSettingsWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.12.2022.
//

import StackNinja
import UIKit

protocol ChallengeSettingsWorksProtocol {
   var showCandidatesTurnOn: VoidWork { get }
   var showCandidatesTurnOff: VoidWork { get }
   var severalReportsTurnOn: VoidWork { get }
   var severalReportsTurnOff: VoidWork { get }
}

final class ChallengeSettingsWorksStore: InitProtocol {
   var settings: ChallengeSettings?
}

final class ChallengeSettingsWorks<Asset: AssetProtocol>: BaseWorks<ChallengeSettingsWorksStore, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase
}

extension ChallengeSettingsWorks: ChallengeSettingsWorksProtocol {
   var saveInput: Work<ChallengeSettings, ChallengeSettings> { .init { work in
      Self.store.settings = work.in
      work.success(work.in)
   }.retainBy(retainer) }

   var showCandidatesTurnOn: VoidWork { .init { work in
      Self.store.settings?.showContenders = true
      work.success()
   }.retainBy(retainer) }

   var showCandidatesTurnOff: VoidWork { .init { work in
      Self.store.settings?.showContenders = false
      work.success()
   }.retainBy(retainer) }

   var severalReportsTurnOn: VoidWork { .init { work in
      Self.store.settings?.severalReports = true
      work.success()
   }.retainBy(retainer) }

   var severalReportsTurnOff: VoidWork { .init { work in
      Self.store.settings?.severalReports = false
      work.success()
   }.retainBy(retainer) }

   var changeChallengeTypeIndex: In<Int>.Out<ChallengeCreateLoadedParams.ChallengeType> { .init { work in
      guard let settings = Self.store.settings else { work.fail(); return }

      settings.selectedChallengeTypeIndex = work.in
      if let challengeType = settings.selectedChallengeType {
         work.success(challengeType)
      } else {
         work.fail()
      }
   }}


   var getCurrentSettings: Out<ChallengeSettings> { .init { work in
      guard let settings = Self.store.settings else {
         work.fail()
         return
      }
      work.success(settings)
   }.retainBy(retainer) }
}
