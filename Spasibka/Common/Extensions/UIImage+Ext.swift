//
//  UIImage+Ext.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.11.2022.
//

import UIKit

extension UIImage {

   /// Возвращает сумму яркостей пикселей изображения
   var brightness: CGFloat {
      guard
         let cgImage = cgImage,
         let providerData = cgImage.dataProvider?.data,
         let data = CFDataGetBytePtr(providerData)
      else { return 0 }

      let numberOfComponents = cgImage.bitsPerPixel / 8
      var sum: CGFloat = 0
      var count: CGFloat = 0
      for yPos in 0 ..< cgImage.height {
         for xPos in 0 ..< cgImage.width {
            let pixelData = ((Int(cgImage.width) * yPos) + xPos) * numberOfComponents

            var pixelSum: CGFloat = 0
            for index in 0 ..< numberOfComponents - 1 {
               pixelSum += CGFloat(data[pixelData + index]) / 255.0
            }
            let pixelBright = pixelSum / CGFloat(numberOfComponents - 1)

            count += 1
            sum += pixelBright
         }
      }

      return sum / count
   }

   /// Возвращает выбранную область изображения (cropping)
   func cropped(rect: CGRect) -> UIImage {
      guard
         let cgImage = cgImage,
         let cropped = cgImage.cropping(to: rect)
      else { return self }

      let image = UIImage(cgImage: cropped)
      return image
   }

   func resized(to size: CGSize) -> UIImage {
      guard self.size.width > size.width else { return self }

      return UIGraphicsImageRenderer(size: size).image { _ in
         draw(in: CGRect(origin: .zero, size: size))
      }
   }

   func sideLengthLimited(to widthHeight: CGFloat) -> UIImage {
      let horizontal = size.width >= size.height
      let coef = horizontal ? size.width / size.height : size.height / size.width
      let newSize = horizontal ? CGSize(width: widthHeight, height: widthHeight / coef) : CGSize(width: widthHeight / coef, height: widthHeight)

      return UIGraphicsImageRenderer(size: newSize).image { _ in
         draw(in: CGRect(origin: .zero, size: newSize))
      }
   }
   
   func insetted(_ inset: CGFloat) -> UIImage {
      let width: CGFloat = size.width + inset * 2
      let height: CGFloat = size.height + inset * 2
      UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
      let origin: CGPoint = CGPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
      draw(at: origin)
      let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return imageWithPadding ?? self
   }

}
