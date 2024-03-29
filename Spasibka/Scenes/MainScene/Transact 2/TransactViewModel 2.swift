//
//  TransactViewModel.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 09.07.2022.
//

import ReactiveWorks
import UIKit

struct TransactViewEvent: InitProtocol {}

final class TransactViewModel<Asset: AssetProtocol>: BaseViewModel<UIStackView>,
   Communicable,
   Stateable,
   Assetable,
   WorkableModel
{
   typealias State = StackState

   var eventsStore: TransactViewEvent = .init()

   // MARK: - View Models

   private lazy var digitalThanksTitle = Design.label.headline4
      .set(.text(Text.title.make(\.digitalThanks)))
      .set(.numberOfLines(1))
      .set(.alignment(.left))
      .set(.padding(.init(top: 22, left: 0, bottom: 26, right: 0)))

   private lazy var userSearchTextField = TextFieldModel()
      .set(.backColor(.init(red: 0.33, green: 0.33, blue: 0.33, alpha: 0.08)))
      .set(.height(48))
      .set(.placeholder(Text.title.make(\.chooseRecipient)))
      .set(.hidden(true))
      .set(.padding(.init(top: 0, left: 16, bottom: 0, right: 16)))

   private lazy var transactInputViewModel = TransactInputViewModel<Design>()
      .set(.leftCaptionText(Text.title.make(\.sendThanks)))
      .set(.rightCaptionText(Text.title.make(\.availableThanks)))
      .set(.hidden(true))

   private lazy var tableModel = TableViewModel()
      .set(.borderColor(.gray))
      .set(.borderWidth(1))
      .set(.cornerRadius(Design.Parameters.cornerRadius))
      .set(.hidden(true))

   private lazy var sendButton = Design.button.default
      .set(Design.State.button.inactive)
      .set(.title(Text.button.make(\.sendButton)))
      .set(.hidden(true))

   private lazy var reasonTextView = TextViewModel()
      .set(.padding(.init(top: 16, left: 16, bottom: 16, right: 16)))
      .set(.placeholder(Texts.title.reasonPlaceholder))
      .set(.backColor(UIColor.clear))
      .set(.borderColor(.lightGray.withAlphaComponent(0.4)))
      .set(.borderWidth(1.0))
      .set(.font(Design.font.body1))
      .set(.height(200))
      .set(.hidden(true))

   private lazy var transactionStatusView = TransactionStatusViewModel<Asset>()

   // MARK: - Interactor

   lazy var works = TransactSceneWorks<Asset>()

   // MARK: - Start

   override func start() {
      configure()

      weak var wS = self

      works.loadTokens
         .doAsync()
         .onSuccess {
            wS?.userSearchTextField.set(.hidden(false))
         }
         .onFail {
            wS?.userSearchTextField.set(.hidden(true))
         }
         .doNext(work: works.loadBalance)
         .onSuccess {
            wS?.transactInputViewModel.set(.rightCaptionText(
               Text.title.make(\.availableThanks) + " " + String($0.distr.amount)
            ))
         }
         .onFail {
            print("balance not loaded")
         }

      userSearchTextField
         .onEvent(\.didEditingChanged)
         .onSuccess {
            wS?.hideHUD()
         }
         .doNext(usecase: IsNotEmpty())
         .onSuccess {
            wS?.tableModel.set(.hidden(true))
         }
         .doNext(work: works.searchUser)
         .onSuccess {
            wS?.presentFoundUsers(users: $0)
         }
         .onFail {
            print("Search user API Error")
         }


      sendButton
         .onEvent(\.didTap)
         .doInput {
            // TODO: - View запрещено, хранить текст в TempStore -> SceneWorks
            wS?.transactInputViewModel.textField.view.text
         }
         .doMap { (amount: String) in
            let reason = wS?.reasonTextView.view.text ?? ""
            return (amount, reason)
         }
         .doNext(work: works.sendCoins)
         .onSuccess { tuple in
            wS?.transactionStatusView.start()
            guard // ))) значит этому тут не место)) надо придумать механизм
               let superview = wS?.view.superview?.superview?.superview?.superview?.superview
            else { return }
            let input = StatusViewInput(baseView: superview,
                                        sendCoinInfo: tuple.info,
                                        username: tuple.recipient)
            wS?.transactionStatusView.sendEvent(\.presentOnScene, input)
            wS?.setToInitialCondition()
         }
         .onFail {
            wS?.presentAlert(text: "Не могу послать деньгу")
         }

      tableModel
         .onEvent(\.didSelectRow)
         .doNext(work: works.mapIndexToUser)
         .onSuccess { foundUser in
            let fullName = foundUser.name + " " + foundUser.surname
            wS?.userSearchTextField.set(.text(fullName))
            wS?.tableModel.set(.hidden(true))
            wS?.transactInputViewModel.set(.hidden(false))
            wS?.sendButton.set(.hidden(false))
            wS?.reasonTextView.set(.hidden(false))
         }

      configureInputParsers()
   }

   func configure() {
      set(.axis(.vertical))
      set(.distribution(.fill))
      set(.alignment(.fill))
      set(.spacing(8))
      set(.models([
         digitalThanksTitle,
         userSearchTextField,
         transactInputViewModel,
         reasonTextView,
         sendButton,
         tableModel,
         Spacer(),
      ]))
   }

   private func setToInitialCondition() {
      userSearchTextField.set(.text(""))
      transactInputViewModel.set(.hidden(true))
      transactInputViewModel.textField.set(.text(""))
      sendButton.set(.hidden(true))
      reasonTextView.set(.text(""))
      reasonTextView.set(.hidden(true))
   }

   private func presentAlert(text: String) {
      let alert = UIAlertController(title: "Ошибка",
                                    message: text,
                                    preferredStyle: .alert)

      alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                    style: .default))

      UIApplication.shared.keyWindow?.rootViewController?
         .present(alert, animated: true, completion: nil)
   }
}

private extension TransactViewModel {
   func hideHUD() {
      transactInputViewModel.set(.hidden(true))
      sendButton.set(.hidden(true))
      reasonTextView.set(.hidden(true))
   }

   func presentFoundUsers(users: [FoundUser]) {
      let found = users.map { $0.name + " " + $0.surname }
      let cellModels = found.map { name -> LabelCellModel in
         let cellModel = LabelCellModel()
         cellModel.set(.text(name))
         return cellModel
      }
      tableModel.set(.models(cellModels))
      tableModel.set(.hidden(found.isEmpty ? true : false))
   }
}

private extension TransactViewModel {
   func configureInputParsers() {
      weak var wS = self

      var correctCoinInput = false
      var correctReasonInput = false

      transactInputViewModel.textField
         .onEvent(\.didEditingChanged)
         .doNext(work: works.coinInputParsing)
         .onSuccess {
            wS?.transactInputViewModel.textField.set(.text($0))
            correctCoinInput = true
            if correctReasonInput == true {
               wS?.sendButton.set(Design.State.button.default)
            }
         }
         .onFail { (text: String) in
            wS?.transactInputViewModel.textField.set(.text(text))
            wS?.sendButton.set(Design.State.button.inactive)
         }

      reasonTextView
         .onEvent(\.didEditingChanged)
         .doNext(work: works.reasonInputParsing)
         .onSuccess {
            wS?.reasonTextView.set(.text($0))
            correctReasonInput = true
            if correctCoinInput == true {
               wS?.sendButton.set(Design.State.button.default)
            }
         }
         .onFail { (text: String) in
            wS?.reasonTextView.set(.text(text))
            correctReasonInput = false
            wS?.sendButton.set(Design.State.button.inactive)
         }
   }
}
