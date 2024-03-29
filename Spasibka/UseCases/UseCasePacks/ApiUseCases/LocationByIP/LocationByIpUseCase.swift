//
//  LocationByIpUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.12.2022.
//

import StackNinja

struct LocationByIpUseCase: UseCaseProtocol {
   let locationByApiWorker: LocationByIpApiWorker

   var work: Work<Void, LocationByIp> {
      locationByApiWorker.work
   }
}
