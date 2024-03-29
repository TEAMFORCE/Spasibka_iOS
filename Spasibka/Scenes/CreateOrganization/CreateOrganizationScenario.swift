//
//  CreateOrganizationScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.07.2023.
//

import StackNinja
import Foundation

struct CreateOrganizationScenarioInputEvent: ScenarioEvents {
   let initial: Out<CommunityParams>
   let didOrgTitleChanged: Out<String>
   let didChangeModeTapped: VoidWork

   let usersStartBalanceEditingChanged: Out<String>
   let headStartBalanceEditingChanged: Out<String>

   let startDatePicked: Out<Date>
   let endDatePicked: Out<Date>

   let startCreateCommunity: VoidWork
}

final class CreateOrganizationScenario: BaseScenario<Onboard2PageState, CreateOrganizationScenarioInputEvent> {
   private let retainer = Retainer()
   private var store = CreateOrganizationStore()

   override func configure() {
      super.configure()

      Work.startVoid
         .retainBy(retainer)
         .doCombineLatest(
            events.usersStartBalanceEditingChanged,
            events.headStartBalanceEditingChanged,
            events.didOrgTitleChanged
         )
         .doCheck {
            return (!$0.isEmpty && !$1.isEmpty) && $2.count > 2
         }
         .onSuccess(self) {
            $0.setState(.createButtonEnabled)
         }
         .onFail(self) {
            $0.setState(.createButtonDisabled)
         }

      events.initial
         .doNext(setInitial)
         .doSendEvent(events.didOrgTitleChanged)

      events.didOrgTitleChanged
         .doNext(updateTitle)

      events.headStartBalanceEditingChanged
         .doNext(updateUserStartBalance)

      events.usersStartBalanceEditingChanged
         .doNext(updateHeadStartBalance)

      events.usersStartBalanceEditingChanged
         .sendAsyncEvent("50")

      events.headStartBalanceEditingChanged
         .sendAsyncEvent("50")

      events.didChangeModeTapped
         .doNext(changeConfigMode)
         .onSuccess(setState, .automatic)
         .onFail(setState, .manual)

      events.startDatePicked
         .doNext(updateStartDate)
         .onSuccess(setState) { .correctEndPicker(startDate: $0) }

      events.endDatePicked
         .doNext(updateEndDate)
         .onSuccess(setState) { .correctStartPicker(endDate: $0) }

      events.startCreateCommunity
         .doNext(getCommunityParams)
         .onSuccess(setState) { .sendCreateCommunityRequest($0) }
   }
}

final class CreateOrganizationStore: InitProtocol {
   var isAutomaticConfigMode = true
   var params = CommunityParams(
      startDate: .init(),
      endDate: .init(),
      startBalance: 0,
      headStartBalance: 0
   )
}

private extension CreateOrganizationScenario {

   var setInitial: In<CommunityParams>.Out<String> { .init { [weak self] work in
      self?.store.params = work.in
      work.success(work.in.name.unwrap)
   }}

   var updateTitle: In<String> { .init { [weak self] work in
      self?.store.params.name = work.in

      work.success()
   }}

   var updateUserStartBalance: In<String> { .init { [weak self] work in
      self?.store.params.startBalance = UInt(work.in) ?? 50

      work.success()
   }}

   var updateHeadStartBalance: In<String> { .init { [weak self] work in
      self?.store.params.headStartBalance = UInt(work.in) ?? 50

      work.success()
   }}

   var updateStartDate: In<Date>.Out<Date> { .init { [weak self] work in
      self?.store.params.startDate = work.in

      work.success(work.in)
   }}

   var updateEndDate: In<Date>.Out<Date> { .init { [weak self] work in
      self?.store.params.endDate = work.in

      work.success(work.in)
   }}

   var getCommunityParams: Out<CommunityParams> { .init { [weak self] work in
      guard let params = self?.store.params else { work.fail(); return }

      work.success(params)
   }}

   var changeConfigMode: VoidWork { .init { [weak self] in
      guard let store = self?.store else { return }
      store.isAutomaticConfigMode.toggle()

      if store.isAutomaticConfigMode {
         $0.success()
      } else {
         $0.fail()
      }
   }}
}
