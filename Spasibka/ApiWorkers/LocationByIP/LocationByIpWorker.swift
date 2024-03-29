//
//  LocationByIp.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.12.2022.
//

import Foundation

import StackNinja

struct LocationByIp: Decodable {
   let status: String? //  ":"success",
   let country: String? //  ":"Turkey",
   let countryCode: String? //  ":"TR",
   let region: String? //  ":"07",
   let regionName: String? //  ":"Antalya",
   let city: String? //  ":"Alanya",
   let zip: String? //  ":"07400",
   let lat: Double? //  ":36.5398,
   let lon: Double? //  ":32.0012,
   let timezone: String? //  ":"Europe/Istanbul",
   let isp: String? //  ":"Alanyanet internet iletisim",
   let org: String? //  ":"Alanyanet internet iletisim Teknolojileri San. Tic. Ltd.",
   let `as`: String? //  ":"AS209007 WIFI TELEKOM BILISIM SANAYI VE TICARET ANONIM SIRKETI",
   let query: String? //  ":"45.11.42.50"
}

final class LocationByIpApiWorker: BaseApiWorker<Void, LocationByIp> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: CommonEndpoints.locationByIpEndpoint())
         .done { result in
            let decoder = DataToDecodableParser()

            guard
               let data = result.data,
               let location: LocationByIp = decoder.parse(data)
            else {
               work.fail()
               return
            }

            work.success(result: location)
         }
         .catch { error in
            print(error.localizedDescription)
            work.fail()
         }
   }
}
