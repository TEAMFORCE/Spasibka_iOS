//
//  LocationWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.12.2022.
//

import CoreLocation
import StackNinja

protocol LocationWorksStorage: InitClassProtocol {
   var userLocationWork: Work<Void, CLLocation>? { get set } // Works that will be used for location (GPS/IP)
}

enum GeoCodingPlacemark {
   case name
   case locality
   case subLocality
   case administrativeArea
   case country
}

protocol LocationWorksProtocol: StoringWorksProtocol, ApiUseCaseable where Store: LocationWorksStorage {
   var locationManager: LocationManager { get }
   //
   var startUpdatingLocation: Work<Void, Void> { get }
}

extension LocationWorksProtocol {
   var startUpdatingLocation: Work<Void, Void> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      if self.locationManager.isEnabled {
         Self.store.userLocationWork = self.locationManager.on(\.didUpdateLocation)
         self.locationManager.start()
         work.success()
      } else {
         Self.store.userLocationWork = self.getUserLocationByIP
         work.success()
         Self.store.userLocationWork?
            .doOnQueue(.globalBackground)
            .doAsync()
      }
   }.retainBy(retainer) }

   var getUserLocationData: Work<[GeoCodingPlacemark], UserLocationData> { .init { work in
      let geocoder = CLGeocoder()
      let placemarkTag = work.unsafeInput

      Self.store.userLocationWork?.onSuccess { location in
         geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let _ = error {
               work.fail()
            } else if let placemarks = placemarks {
               let placemark = placemarks.first

               let text = [
                  placemarkTag.contains(.name) ? placemark?.name : nil,
                  placemarkTag.contains(.locality) ? placemark?.locality : nil,
                  placemarkTag.contains(.subLocality) ? placemark?.subLocality : nil,
                  placemarkTag.contains(.administrativeArea) ? placemark?.administrativeArea : nil,
                  placemarkTag.contains(.country) ? placemark?.country : nil
               ]
               .compactMap { $0 }
               .joined(separator: ", ")

               let result = UserLocationData(
                  locationName: text,
                  geoPosition: location.coordinate
               )

               work.success(result)
            }
         }
      }

   }.retainBy(retainer) }

   // MARK: - Private

   private var getUserLocationByIP: Work<Void, CLLocation> { .init { [weak self] work in
      self?.apiUseCase.getLocationByIP
         .doOnQueue(.globalBackground)
         .doAsync()
         .onSuccess {
            guard let lat = $0.lat, let lon = $0.lon else { work.fail(); return }
            let clLocation = CLLocation(latitude: lat, longitude: lon)

            work.success(clLocation)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}
