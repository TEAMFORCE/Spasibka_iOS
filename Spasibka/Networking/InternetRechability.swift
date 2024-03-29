//
//  InternetRechability.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.10.2022.
//

import Alamofire
import ReactiveWorks

struct InternetRechability {
   private static let sharedInstance = NetworkReachabilityManager()!

   static var isConnectedToInternet: Bool {
      sharedInstance.isReachable
   }

   static var isNoInternet: Bool { !isConnectedToInternet }
}

final class InetCheckWorker: WorkerProtocol {
   func doAsync(work: VoidWork) {
      if InternetRechability.isConnectedToInternet {
         work.success()
      } else {
         work.fail()
      }
   }
}
