//
//  ImageLoadingWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.01.2023.
//

import StackNinja
import UIKit
import Alamofire

protocol ImageLoadingWorkStorageProtocol: InitClassProtocol {
   var loadedImage: [UIImage] { get set }
}

protocol ImageLoadingWorks: StoringWorksProtocol where Self.Store: ImageLoadingWorkStorageProtocol {
   var loadImageGroup: GroupWork<String, UIImage> { get }
}

extension ImageLoadingWorks {
   var loadImageGroup: GroupWork<String, UIImage> { .init { work in
      let url = work.unsafeInput
      
      ImageViewModel() // так кэшируется! а так нет: AF.request(url).responseImage
         .indirectUrl(url) { _, image in
            if let image {
               Self.store.loadedImage.append(image)
               work.success(image)
            } else {
               work.fail()
            }
         }
   } }
}

