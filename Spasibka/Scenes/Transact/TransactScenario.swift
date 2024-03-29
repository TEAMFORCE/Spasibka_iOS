//
//  TransactScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

import StackNinja
import UIKit

struct TransactScenarioEvents: ScenarioEvents {
   let userSearchTXTFLDBeginEditing: Out<String>
   let userSearchTFDidEditingChanged: Out<String>
   let userSelected: Out<Int>
   let sendButtonEvent: Out<Void>

   let amountInputChanged: Out<String>
   let reasonInputChanged: Out<String>

   let anonymousSetOff: Out<Void>
   let anonymousSetOn: Out<Void>

   let setTags: Out<Set<Tag>>

   let cancelButtonDidTap: VoidWork

   let selectedUserId: Out<Int>

   let changePublicMode: Out<Bool>

   let addStickerButtonPressed: VoidWork
   let didSelectStickerAtIndex: Out<Int>
   let removeSelectedSticker: Out<UIImage>
   
   let requestPagination: VoidWork
}

final class TransactScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<TransactScenarioEvents, TransactState, TransactWorks<Asset>>
{
   override func configure() {
      super.configure()

      start
         //
         .doNext(works.reset)
         .doNext(works.loadTokens)
         .onSuccess(setState, .loadTokensSuccess)
         .onFail(setState, .error)
         // load org id
         .doNext(works.setOrganizationID)
         .onFail(setState, .error)
         // then load balance
         .doNext(works.loadBalance)
         .onSuccess(setState) { .loadBalanceSuccess($0.distr.amount, $0.income.amount) }
         .onFail(setState, .error)
         // then break to void and load 10 user list
         .doVoidNext(works.getUserList)
         .onSuccess(setState) { .loadUsersListSuccess($0) }
         .onFail(setState, .error)
         // load tags
         .doVoidNext(works.loadTags)
         .doNext(works.getSelectableTags)
         .onSuccess(setState) { .setLoadedSelctableTagsToTagList($0) }
         .doVoidNext(works.getIsAnonymousAvailable)
         .onSuccess(setState) { .enableAnonymousAvailable($0) }

      events.userSearchTXTFLDBeginEditing
         .doNext(IsEmpty())
         .doVoidNext(works.getUserList)
         .onSuccess(setState) { .presentFoundUser($0) }

      // on input event, then check input is not empty, then search user
      events.userSearchTFDidEditingChanged
         .onSuccess(setState, .userSearchTFDidEditingChangedSuccess)
         .doNext(IsNotEmpty())
         .onFail { [weak self] (_: String) in
            self?.works.getUserList
               .doAsync()
               .onSuccess(self?.setState) {
                  .presentUsers($0)
               }
               .onFail(self?.setState, .error)
         }
         .doNext(works.searchUser)
         .onSuccess(setState) { .listOfFoundUsers($0) }
         .onFail(setState, .error)

      events.userSelected
         .doSaveResult()
         .doNext(works.mapIndexToUser)
         .onSuccessMixSaved(setState) { .userSelectedSuccess($0, $1, false) }

      events.sendButtonEvent
         .onSuccess(setState, .sendButtonPressed)
         .doNext(works.sendCoins)
         .onSuccess(setState) { .sendCoinSuccess($0) }
         .onFail(setState, .sendCoinError)
         .doVoidNext(works.reset)

      events.amountInputChanged
         .doNext(works.coinInputParsing)
         .onSuccess(setState) { .coinInputSuccess($0, true) }
         .onFail { [weak self] (text: String) in
            self?.setState(.resetCoinInput)
            self?.works.updateAmount
               .doAsync((text, false))
               .onSuccess(self?.setState) { .coinInputSuccess(text, false) }
         }
         .doAnyway()
         .doSaveResult() // save text
         .doMap { ($0, true) }
         .doNext(works.updateAmount)
         .doNext(works.isCorrectBothInputs)
         .onSuccessMixSaved(setState) { _, savedText in
            .coinInputSuccess(savedText, true)
         }
         .onFailMixSaved(setState) { _, savedText in
            .coinInputSuccess(savedText, false)
         }

      events.reasonInputChanged
//         .doNext(works.inputTextCacher)
//         .onSuccess(setState) { .updateReasonFieldText($0) }
         .doNext(works.reasonInputParsing)
         .onFail { [weak self] (text: String) in
            self?.works.updateReason
               .doAsync((text, false))
               .onSuccess(self?.setState, .reasonInputSuccess(text, false))
         }
         .doAnyway()
         .doSaveResult()
         .doMap { ($0, true) }
         .doNext(works.updateReason)
         .doNext(works.isCorrectBothInputs)
         .onSuccessMixSaved(setState) {
            .reasonInputSuccess($1, true)
         }
         .onFailMixSaved(setState) {
            .reasonInputSuccess($1, false)
         }

      events.anonymousSetOff
         .doNext(works.anonymousOff)

      events.anonymousSetOn
         .doNext(works.anonymousOn)

      events.cancelButtonDidTap
         .onSuccess(setState, .cancelButtonPressed)

      events.setTags
         .doNext(works.setTags)
         .doNext(works.getSelectedTags)
         .doSaveResult()
         .doVoidNext(works.isCorrectBothInputs)
         .onSuccessMixSaved(setState) { .updateSelectedTags($1, true) }
         .onFailMixSaved(setState) { .updateSelectedTags($1, false) }

      events.selectedUserId
         .doNext(works.loadProfileById)
         .onSuccess(setState) { .userSelectedSuccess($0, 0, true) }

      events.changePublicMode
         .doNext(works.changePublicMode)

      events.addStickerButtonPressed
         .onSuccess(setState, .presentStickerSelector)
         .doNext(works.loadStickers)
         .onSuccess(setState) { .setPlaceholdersForStickersCount($0.count) }
         .doNext(works.loadStickerImages)
         .onEachResult(setState) { image, index in
            .addImageToStickerSelector(image, index)
         }

      events.didSelectStickerAtIndex
         .doNext(works.didSelectStickerIndex)
         .onSuccess(setState, .setHideAddStickerButton(true))

      events.removeSelectedSticker
         .doVoidNext(works.removeSelectedSticker)
         .onSuccess(setState, .setHideAddStickerButton(false))
      
      events.requestPagination
         .onSuccess {
            print("hi")
         }
         .onFail {
            print("fail")
         }
   }
}
