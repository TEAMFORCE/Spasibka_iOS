//
//  MapsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import MapKit
import StackNinja

// MARK: - MapsViewModel

final class MapsViewModel: BaseViewModel<MKMapView> {
   override func start() {
      view.isZoomEnabled = false
      view.isScrollEnabled = false
      view.showsUserLocation = false
   }
}

extension MapsViewModel: Stateable {
   typealias State = ViewState
}

extension MapsViewModel: StateMachine {
   enum MapState {
      case region(MKCoordinateRegion)
   }

   func setState(_ state: MapState) {
      switch state {
      case .region(let region):
         view.region = region
      }
   }
}
