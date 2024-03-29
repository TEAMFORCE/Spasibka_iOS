//
//  LinkTappingLabel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import StackNinja
import Foundation
import UIKit

final class LinkTappingLabel: TextViewModel, Eventable3 {

   var events3: EventsStore = EventsStore()

   struct Events3: InitProtocol {
      var didTapLink: URL?
   }

   override func start() {
      super.start()

      let labelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:)))
      view.isUserInteractionEnabled = true
      view.addGestureRecognizer(labelTap)
      view.isEditable = false
      view.isSelectable = false
      view.isScrollEnabled = false
      
      let padding = view.textContainer.lineFragmentPadding
      view.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
   }

   @objc private func didTapLabel(_ recognizer: UITapGestureRecognizer) {
      guard let attributedText = view.attributedText else {
         return
      }

      let layoutManager = NSLayoutManager()
      let textContainer = NSTextContainer(size: .zero)
      let textStorage = NSTextStorage(attributedString: attributedText)

      layoutManager.addTextContainer(textContainer)
      textStorage.addLayoutManager(layoutManager)

      let location = recognizer.location(in: view)
      let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

      attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length), options: []) { attribute, range, _ in
         if let link = attribute as? URL, NSLocationInRange(characterIndex, range) {
            // Handle the URL as needed
            send(\.didTapLink, link)
         }
      }
   }
}


