//
//  BaseApiWorker.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import ReactiveWorks

class BaseApiWorker<In, Out>: ApiProtocol, WorkerProtocol {
   var apiEngine: ApiEngineProtocol?

   init(apiEngine: ApiEngineProtocol) {
      self.apiEngine = apiEngine
   }

   func doAsync(work _: Work<In, Out>) {
      fatalError()
   }
}

