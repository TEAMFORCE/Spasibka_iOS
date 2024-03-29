//
//  Onboarding2Works.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

final class Onboarding2Store<Asset: ASP>: InitClassProtocol {}

protocol UpdateOrganizationParamsProtocol: WorksProtocol, ApiUseCaseable {}

extension UpdateOrganizationParamsProtocol {
   var updateCommunityPeriod: In<CommunityParams> { .init { [weak self] work in
      let params = work.in
      self?.apiUseCase.createPeriod
         .doAsync(
            .init(
               startDate: params.startDate.convertToString(.yyyyMMdd),
               endDate: params.endDate.convertToString(.yyyyMMdd),
               default: nil,
               distrAmount: Int(params.startBalance),
               headDistrAmount: Int(params.headStartBalance),
               organizationId: params.organizationId
            )
         )
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}

final class Onboarding2Works<Asset: ASP>:
   BaseWorks<Onboarding2Store<Asset>, Asset>,
   UpdateOrganizationParamsProtocol
{

   let apiUseCase = Asset.apiUseCase

   var loadInviteLink: Out<String> { .init { [weak self] work in
      self?.apiUseCase.getInviteLink
         .doAsync()
         .onSuccess {
            work.success($0.inviteLink)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}
