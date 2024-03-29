//
//  AboutWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.12.2022.
//

import CoreLocation
import StackNinja

final class AboutWorksStorage: InitClassProtocol, LocationWorksStorage {
   var userLocationWork: Work<Void, CLLocation>?
}

final class AboutWorks<Asset: ASP>: BaseWorks<AboutWorksStorage, Asset>, LocationWorksProtocol {
   lazy var locationManager: LocationManager = .init()
   lazy var apiUseCase: ApiUseCase<Asset> = .init()

   var getLicenseEnd: Work<Void, String> { .init { [weak self] work in
      self?.apiUseCase.getOrganizationSettings
         .doAsync()
         .onSuccess {
            if let licence = $0.licenseEnd {
               work.success(licence)
            } else {
               work.fail()
            }
         }
         .onFail { work.fail() }
   }.retainBy(retainer) }
}
