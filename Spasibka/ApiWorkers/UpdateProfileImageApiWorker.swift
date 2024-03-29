//
//  UpdateProfileImageApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.08.2022.
//

import Foundation
import StackNinja
import UIKit

struct UpdateImageRequest {
   let token: String
   let id: Int
   let photo: UIImage
   let croppedPhoto: UIImage?
}

final class UpdateProfileImageApiWorker: BaseApiWorker<UpdateImageRequest, Void> {
   override func doAsync(work: Work<UpdateImageRequest, Void>) {
      let cookieName = "csrftoken"
      
      guard
         let updateImageRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.UpdateProfileImage(
         id: String(updateImageRequest.id),
         headers: [Config.tokenHeaderKey: updateImageRequest.token,
                   "X-CSRFToken": cookie.value]
      )
      print("endpoint is \(endpoint)")
      var images: [UIImage] = []
      
      images.append(updateImageRequest.photo)
      
      if let cropped = updateImageRequest.croppedPhoto {
         images.append(cropped)
      }
      
      apiEngine?
         .processWithImages(endpoint: endpoint,
                            images: images,
                            names: ["photo", "cropped_photo"])
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
      
//      apiEngine?
//         .processWithImage(endpoint: endpoint,
//                           image: updateImageRequest.photo)
//         .done { result in
//            work.success()
//         }
//         .catch { _ in
//            work.fail()
//         }
   }
}
