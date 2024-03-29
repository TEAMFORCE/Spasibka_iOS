//
//  SortableImageWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.10.2023.
//

import StackNinja
import UIKit

protocol SortableImageStorage: InitClassProtocol {
   var maxImagesCount: Int { get }
   var fileList: [FileList] { get set }
}

protocol SortableImageWorks: StorageProtocol, WorksProtocol where Self.Store: SortableImageStorage {}

extension SortableImageWorks {
   func setFileList(_ fileList: [FileList]) {
      var fileList = fileList
      if fileList.count > Self.store.maxImagesCount {
         fileList = Array(fileList[0 ..< Self.store.maxImagesCount])
      }
      Self.store.fileList = fileList
   }

   func addImage(_ image: UIImage) -> UIImage {
      let startIndex = Self.store.fileList.count
      let fileList = FileList(
         sortIndex: startIndex + 1,
         index: nil,
         filename: "photo\(startIndex + 1).jpg",
         image: image
      )
      Self.store.fileList.append(fileList)
      return image
   }

   func removeImageAtIndex(_ index: Int) {
      Self.store.fileList.remove(at: index)
   }

   func checkIsFull() -> Bool {
      Self.store.fileList.count >= Self.store.maxImagesCount
   }

   func checkIsEmpty() -> Bool {
      Self.store.fileList.isEmpty
   }

   func getImagesCount() -> Int {
      Self.store.fileList.count
   }

   func getImagesCountLeft() -> Int {
      Self.store.maxImagesCount - Self.store.fileList.count
   }

   func moveImage(_ postions: (from: Int, to: Int)) {
      guard
         let movingFileList = Self.store.fileList[safe: postions.from]
      else { return }

      let newList = FileList(
         sortIndex: postions.to,
         index: movingFileList.index,
         filename: movingFileList.filename,
         image: movingFileList.image
      )
      Self.store.fileList.remove(at: postions.from)

      let newIndex = postions.to
      Self.store.fileList.insert(newList, at: newIndex)
      if postions.from > postions.to {
         for i in newIndex ..< Self.store.fileList.count {
            let list = Self.store.fileList[i]
            let sortIndex = list.sortIndex + 1
            let new = FileList(
               sortIndex: sortIndex,
               index: list.index,
               filename: list.filename,
               image: list.image
            )
            Self.store.fileList[i] = new
         }
      } else if postions.from < postions.to {
         for i in postions.from ..< newIndex {
            let list = Self.store.fileList[i]
            let new = FileList(
               sortIndex: list.sortIndex - 1,
               index: list.index,
               filename: list.filename,
               image: list.image
            )
            Self.store.fileList[i] = new
         }
      }
   }
}
