//
//  ImageWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.10.2022.
//

import StackNinja
import UIKit

protocol ImageStorage: InitClassProtocol {
   var images: [UIImage] { get set }
   var indexes: [Int] { get set }
}

protocol ImageWorks: StorageProtocol, WorksProtocol where Self.Store: ImageStorage {}

extension ImageWorks {
   var addImage: Work<UIImage, UIImage> { .init { work in
      Self.store.images.append(work.unsafeInput)
      Self.store.indexes.append(Self.store.images.count)
      work.success(result: work.unsafeInput)
   } }

   var removeImage: Work<UIImage, Void> { .init { work in
      for (i, value) in Self.store.images.enumerated() {
         if value === work.unsafeInput {
            Self.store.indexes.remove(at: i)
         }
      }
      Self.store.images = Self.store.images.filter { $0 !== work.unsafeInput }
      work.success()
   } }
   
   var checkIsFull: Work<Void, Bool> { .init { work in
      work.success(result: Self.store.images.count >= 10)
   } }
   
   var checkIsEmpty: Work<Void, Bool> { .init { work in
      work.success(result: Self.store.images.isEmpty)
   } }
   
   var getSelectedCount: Out<Int> { .init { work in
      work.success(Self.store.images.count)
   } }
}
