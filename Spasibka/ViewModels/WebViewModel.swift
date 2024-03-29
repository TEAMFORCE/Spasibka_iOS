//
//  WebViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2023.
//

import StackNinja
import WebKit

final class WebViewModel: BaseViewModel<WKWebView>, Stateable, Eventable {
   typealias State = ViewState

   struct Events: InitProtocol {
      var didFinishNavigation: (currentURLString: String, navigation: WKNavigation)?
      var willNavigateToURLString: String?
   }

   var events = EventsStore()

   override func start() {
      view.navigationDelegate = self
      view.scrollView.isScrollEnabled = false
   }

   @discardableResult func scrollBackColor(_ value: UIColor) -> Self {
      view.scrollView.backgroundColor = value
      return self
   }

   @discardableResult func url(_ value: URL) -> Self {
      view.load(.init(url: value))
      return self
   }
}

extension WebViewModel: WKNavigationDelegate {
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      guard let currentURLString = webView.url?.absoluteString.lowercased() else { return }

      send(\.didFinishNavigation, (currentURLString: currentURLString, navigation: navigation))
   }
}
