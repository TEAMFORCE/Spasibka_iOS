//
//  CreateCommunityWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.06.2023.
//

import StackNinja

protocol CreateCommunityWorksProtocol: WorksProtocol, ApiUseCaseable {}

extension CreateCommunityWorksProtocol {
   var createCommunityWithTitle: In<String>.Out<CommunityResponse> { .init { [weak self] work in
      self?.apiUseCase
         .createCommunity
         .doAsync(CommunityRequest(name: work.in))
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   } }

   var createCommunityWithParams: In<CommunityParams>.Out<CommunityResponse> { .init { [weak self] work in
      let params = work.in
      self?.apiUseCase
         .createCommunityWithParams
         .doAsync(.init(
            organizationName: params.name.unwrap,
            periodStartDate: params.startDate.convertToString(.yyyyMMdd),
            periodEndDate: params.endDate.convertToString(.yyyyMMdd),
            usersStartBalance: Int(params.startBalance),
            ownerStartBalance: Int(params.headStartBalance)
         ))
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   } }
}
