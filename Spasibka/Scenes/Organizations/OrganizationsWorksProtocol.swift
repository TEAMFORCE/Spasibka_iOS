//
//  OrganizationsWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.06.2023.
//

import StackNinja

protocol OrganizationsWorksProtocol: WorksProtocol, ApiUseCaseable {}

extension OrganizationsWorksProtocol {
   var loadOrganizations: Out<[Organization]> { .init { [weak self] work in
      self?.apiUseCase.getUserOrganizations
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }}
}
