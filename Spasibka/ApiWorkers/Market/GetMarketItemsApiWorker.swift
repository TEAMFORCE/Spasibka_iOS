//
//  GetMarketItemsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.01.2023.
//

import Foundation

protocol SpasibkaConvertedImagesProtocol {
   var images: [BenefitImage]? { get } 
}

extension SpasibkaConvertedImagesProtocol {
   var presentingImages: [BenefitImage]? {
      images?.compactMap {
         BenefitImage(id: $0.id, 
               link: SpasibkaEndpoints.tryConvertToImageUrl($0.link),
               forShowcase: $0.forShowcase)
      }
   }
}

struct BenefitImage: Codable {
   let id: Int?
   let link: String?
   let forShowcase: Bool?
   
   enum CodingKeys: String, CodingKey {
      case id, link
      case forShowcase = "for_showcase"
   }
}

struct Benefit: Codable, SpasibkaConvertedImagesProtocol {
   let id: Int
   let name: String?
   let status: String?
   let description: String?
   let actualTo: String?
   let rest: Int?
   let sold: Int?
   let selected: Int?
   let price: Price?
   let categories: [Category]?
   let categoryId: Int?
   let categoryName: String?
   let orderStatus: OrderStatus?
   let images: [BenefitImage]? 
   
   struct Price: Codable {
      let priceInThanks: Int?
      let priceNotInThanks: Int?
      
      enum CodingKeys: String, CodingKey {
         case priceInThanks = "price_in_thanks"
         case priceNotInThanks = "price_not_in_thanks"
      }
   }
   
   struct Category: Codable {
      let categoryId: Int?
      let categoryName: String?
      
      enum CodingKeys: String, CodingKey {
         case categoryId = "category_id"
         case categoryName = "category_name"
      }
   }
   
   enum CodingKeys: String, CodingKey {
      case id, name, images, status, description
      case rest, sold, selected, price, categories
      case actualTo = "actual_to"
      case categoryId = "category_id"
      case categoryName = "category_name"
      case orderStatus = "order_status"
   }
   
   enum OrderStatus: String, Codable {
      case inCart = "C"
      case ordered = "O"
      case `default` = "N"
   }
}

struct MarketRequest {
   let id: Int
   var category: Int? = nil
   var contain: String? = nil
   var minPrice: Int? = nil
   var maxPrice: Int? = nil
}


final class GetMarketItemsApiWorker: BaseApiWorker<(String, MarketRequest), [Benefit]> {
   override func doAsync(work: Wrk) {
      guard
         let token = work.input?.0,
         let request = work.input?.1
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetMarketItems(
            id: request.id,
            contain: request.contain,
            minPrice: request.minPrice,
            maxPrice: request.maxPrice,
            category: request.category,
            headers: [Config.tokenHeaderKey: token]
         )
         )
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let items: [Benefit] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: items)
         }
         .catch { _ in
            work.fail()
         }
   }
}
