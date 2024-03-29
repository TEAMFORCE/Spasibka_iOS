//
//  TransactPopupPresenterProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.01.2023.
//

import StackNinja

protocol TransactPopupPresenterProtocol: SceneModel, Assetable
where Asset: AssetProtocol {
   var bottomPopupPresenter: BottomPopupPresenter { get }
}

extension TransactPopupPresenterProtocol {
   func presentTransactModel(_ model: TransactSceneViewModel<Asset>,
                             completion: VoidClosure? = nil) {
      
      model
         .on(\.sendButtonPressed, self) {
            $0.bottomPopupPresenter.setState(.hide)
         }
         .on(\.finishWithSuccess, self) {
            $0.presentTransactSuccessView($1)
            completion?()
         }
         .on(\.finishWithError, self) {
            $0.presentErrorPopup()
         }
         .on(\.cancelled, self) {
            $0.bottomPopupPresenter.setState(.hide)
         }
      
      bottomPopupPresenter.setState(.present(model: model, onView: vcModel?.view.rootSuperview))
   }
   
   func presentTransactSuccessView(_ data: StatusViewInput) {
      let model = Design.model.transact.transactSuccessViewModel
      self.bottomPopupPresenter.setState(.hide)
      
      model.on(\.finished) { [weak self] in
         self?.bottomPopupPresenter.setState(.hide)
      }
      
      model.on(\.resend) { [weak self] in
         self?.bottomPopupPresenter.setState(.hide)
         let transactModel: TransactSceneViewModel = TransactSceneViewModel<Asset>(vcModel: self?.vcModel)
         self?.presentTransactModel(transactModel)
      }
      
      model.setup(info: data.sendCoinInfo, username: data.username, foundUser: data.foundUser)
      
      bottomPopupPresenter.setState(.present(model: model, onView: vcModel?.view.rootSuperview))
   }
   
   func presentErrorPopup() {
      let model = Design.model.common.systemErrorBlock
      
      model.on(\.didClosed, self) {
         $0.bottomPopupPresenter.setState(.hide)
      }
      
      bottomPopupPresenter.setState(.presentWithAutoHeight(model: model, onView: vcModel?.view.rootSuperview))
   }
}
