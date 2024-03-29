//
//  LocationManager.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2022.
//

import CoreLocation
import StackNinja

struct UserLocationData {
   let locationName: String
   let geoPosition: CLLocationCoordinate2D
}

struct LocationEvents: InitProtocol {
   var didUpdateLocation: CLLocation?
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
   var events: EventsStore = .init()

   private let locationManager = CLLocationManager()

   var isEnabled: Bool {
      if CLLocationManager.locationServicesEnabled() {
         switch locationManager.authorizationStatus {
         case .notDetermined, .restricted, .denied:
            return false
         case .authorizedAlways, .authorizedWhenInUse:
            return true
         @unknown default:
            return false
         }
      } else {
         return false
      }
   }

   func start() {
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let currentLocation = locations.last else { return }

      send(\.didUpdateLocation, currentLocation)
   }

}

extension LocationManager: Eventable {
   typealias Events = LocationEvents
}
