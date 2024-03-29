////
////  UIView+Work.swift
////  Spasibka
////
////  Created by Aleksandr Solovyev on 04.01.2023.
////
//
//import StackNinja
//import ReactiveWorks
//import UIKit
//
//protocol UIViewWork: AnyObject {
//   associatedtype U: UIView
//   init(_ uiView: U)
//   var uiView: UIView? { get }
//}
//
//protocol ViewWorkable: UIView {}
//
//extension ViewWorkable where Self: UIButton {
//   var tapWork: ButtonWork {
//      StaticUIControlHelper.addWork(for: self)
//   }
//}
//
//extension ViewWorkable where Self: UISwitch {
//   var switchWork: SwitcherWork {
//      StaticUIControlHelper.addWork(for: self)
//   }
//}
//
//extension ViewWorkable where Self: UITextField {
//   var textFieldWorks: TextFieldWorks {
//      StaticUIControlHelper.addWork(for: self)
//   }
//}
//
//extension ViewWorkable where Self: UIView {
//   var tapWork: ViewWork {
//      StaticUIControlHelper.addWork(for: self)
//   }
//}
//
//extension UIView: ViewWorkable {}
//
//enum StaticUIControlHelper {
//   private static var works: [any UIViewWork] = []
//
//   static func addWork<T: UIViewWork>(for uiView: T.U) -> T {
//      let work = T(uiView)
//      cleanUnused()
//      works.append(work)
//      return work
//   }
//
//   private static func cleanUnused() {
//      works = works.filter { $0.uiView != nil }
//   }
//}
//
//final class SwitcherWork: Work<Void, Bool>, UIViewWork {
//   private(set) weak var uiView: UIView?
//
//   init(_ uiView: UISwitch) {
//      super.init()
//      uiView.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
//   }
//
//   @objc private func onSwitchValueChanged(_ switcher: UISwitch) {
//      success(switcher.isOn)
//   }
//}
//
//final class ButtonWork: Work<Void, Void>, UIViewWork {
//   private(set) weak var uiView: UIView?
//
//   init(_ uiView: UIButton) {
//      super.init()
//      uiView.addTarget(self, action: #selector(didTap), for: .touchUpInside)
//   }
//
//   @objc private func didTap() {
//      success()
//   }
//}
//
//final class ViewWork: Work<Void, Void>, UIViewWork {
//   private(set) weak var uiView: UIView?
//
//   init(_ uiView: UIView) {
//      super.init()
//      let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
// //     gesture.cancelsTouchesInView = true
//      uiView.isUserInteractionEnabled = true
//      uiView.addGestureRecognizer(gesture)
//   }
//
//   @objc private func didTap() {
//      success()
//   }
//}
//
//final class TextFieldWorks: UIViewWork {
//   private(set) weak var uiView: UIView?
//   private lazy var delegate = TextFieldDelegate(work1: .init(), work2: .init(), work3: .init())
//
//   var didEditingChangedWork: Work<Void, String> { delegate.work1 }
//   var didBeginEditingWork: Work<Void, String> { delegate.work2 }
//   var didEndEditingWork: Work<Void, String> { delegate.work3 }
//
//   init(_ uiView: UITextField) {
//      uiView.delegate = delegate
//      uiView.addTarget(delegate, action: #selector(delegate.changValue(_:)), for: .editingChanged)
//      uiView.addTarget(delegate, action: #selector(delegate.didEditingBegin(_:)), for: .editingDidBegin)
//      uiView.addTarget(delegate, action: #selector(delegate.didEndEditing(_:)), for: .editingDidEnd)
//   }
//}
//
//final class TextFieldDelegate: NSObject, UITextFieldDelegate {
//   let work1: Work<Void, String>
//   let work2: Work<Void, String>
//   let work3: Work<Void, String>
//
//   init(work1: Work<Void, String>, work2: Work<Void, String>, work3: Work<Void, String>) {
//      self.work1 = work1
//      self.work2 = work2
//      self.work3 = work3
//      super.init()
//   }
//
//   @objc func changValue(_ textField: UITextField) {
//      let text = textField.text.string
//      work1.success(text)
//   }
//
//   @objc func didEditingBegin(_ textField: UITextField) {
//      let text = textField.text.string
//      work2.success(text)
//   }
//
//   @objc func didEndEditing(_ textField: UITextField) {
//      let text = textField.text.string
//      work3.success(text)
//   }
//}
