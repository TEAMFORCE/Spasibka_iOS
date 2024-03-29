//
//  BrandImageManager.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.06.2023.
//

import Alamofire
import ReactiveWorks
import UIKit

struct BrandImage {
   let url: String?
   let imageKey: String
}

final class BrandImageManager {
   private let fileStorage: ImageFileStorageProtocol
   private var logoImages: [String: UIImage] = [:]

   private let retainer = Retainer()

   init(fileStorage: ImageFileStorageProtocol) {
      self.fileStorage = fileStorage
   }

   func imageForKey(_ key: String) -> UIImage? {
      if let image = logoImages[key] {
         return image
      }

      if let image = fileStorage.loadImageForKey(key) {
         logoImages[key] = image
         return image
      }

      return nil
   }

   func clearForKeys(_ keys: [String]) {
      keys.forEach {
         logoImages[$0] = nil
         fileStorage.clearForKey($0)
      }
   }

   // MARK: - Private

   // private(set) lazy

   var loadBrandImagesWork: In<[BrandImage]> { .init { [weak self] work in
      let inputs = work.in

      self?.loadImageGroup.doAsync(inputs)
         .onEachResult { [weak self] result, _ in
            guard let image = result.image else {
               self?.fileStorage.clearForKey(result.key)
               self?.logoImages[result.key] = nil
               return
            }

            self?.fileStorage.saveImageForKey(image, key: result.key)
            self?.logoImages[result.key] = image
         }
         .onSuccess { _ in
            work.success()
         }
   }.retainBy(retainer) }

   var loadImageGroup: GroupWork<BrandImage, (key: String, image: UIImage?)> { .init(work: .init { work in
      guard let url = work.in.url else {
         work.success((key: work.in.imageKey, image: nil))
         return
      }

      AF
         .request(url)
         .responseImage { response in
            switch response.result {
            case let .success(image):
               work.success((key: work.in.imageKey, image: image))
            case .failure:
               work.success((key: work.in.imageKey, image: nil))
            }
         }
   }).retainBy(retainer) }
}
