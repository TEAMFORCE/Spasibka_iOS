//
//  ImageFileStorage.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.06.2023.
//

import UIKit

protocol ImageFileStorageProtocol {
   func saveImageForKey(_ image: UIImage, key: String)
   func loadImageForKey(_ key: String) -> UIImage?
   func clearForKey(_ key: String)
}

final class ImageFileStorage: ImageFileStorageProtocol {

   private var fileManager: FileManager { FileManager.default }
   private lazy var directory = NSSearchPathForDirectoriesInDomains(
      .documentDirectory,
      .userDomainMask, true
   )[0]

   func saveImageForKey(_ image: UIImage, key: String) {
      guard let data = image.pngData() else { return }

      let filePath = directory.appending("/\(key).png")

      fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
   }

   func loadImageForKey(_ key: String) -> UIImage? {
      let filePath = directory.appending("/\(key).png")

      return UIImage(contentsOfFile: filePath)
   }

   func clearForKey(_ key: String) {
      let filePath = directory.appending("/\(key).png")

      try? fileManager.removeItem(atPath: filePath)
   }
}
