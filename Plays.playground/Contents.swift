//: A UIKit based Playground for presenting user interface

import PlaygroundSupport
import UIKit
@testable import TeamForce
import StackNinja
import ReactiveWorks

class MyViewController: UIViewController {
   let label = {
      let label = UILabel()
      label.numberOfLines = 0
      label.font = .systemFont(ofSize: 32)
      label.textColor = .black
      return label
   }()

   override func loadView() {
      let view = UIStackView()
      view.backgroundColor = .white
      view.axis = .vertical
      view.distribution = .equalSpacing

      self.view = view
   }

}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

final class TestModel: Eventable {
    struct Events: InitProtocol {
        let event: Int?
    }
    
    var events = EventsStore()
}

print("!!!!!!!!!!!!!!!")
