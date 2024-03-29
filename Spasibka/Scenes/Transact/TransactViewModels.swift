//
//  TransactScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 18.08.2022.
//
import StackNinja
import UIKit

final class TransactViewModels<Design: DSP>: Designable {
   //
//   lazy var balanceInfo = Design.model.transact.balanceInfo.hidden(true)
//   lazy var userSearchTextField = Design.model.transact.userSearchTextField.hidden(true)
   lazy var userSearchModel = Design.model.transact.searchModel.hidden(true)
   lazy var reasonTextView = Design.model.transact.reasonInputTextView
      .hidden(true)
      .minHeight(144)
      .placeholder(Design.text.reasonPlaceholder)
   lazy var amountInputModel = Design.model.transact.amountIputViewModel.hidden(true)
//   lazy var foundUsersList = Design.model.transact.foundUsersList
   lazy var addPhotoButton = Design.model.transact.addPhotoButton.hidden(true)
   lazy var addStickerButton = Design.model.transact.addStickerButton.hidden(true)
   lazy var sendButton = Design.model.transact.sendButton
   lazy var pickedImages = Design.model.transact.pickedImagesPanel.maximumImagesCount(10)
   lazy var notFoundBlock = Design.model.transact.userNotFoundInfoBlock
   lazy var options = Design.model.transact.transactOptionsBlock.hidden(true)
   lazy var tagsCloud = TagsCloud<Design>()
   
   lazy var foundUsersList1 = TableItemsModel()
      .presenters(
         SpacerPresenter.presenter,
         TransactBuilder<Design>.foundUserPresenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
   
//   private lazy var backLogo = BalanceBackLogo<Design>(size: 160.aspected)
//      .padding(.shift(.init(x: 40, y: -73)))
   
   lazy var balanceInfo = Stack<BalanceInfoBlock<Design>>.R<Spacer>.R2<BalanceInfoBlock<Design>>.Ninja()
      .setAll { distr, _, income in
         distr.title
            .text(Design.text.distributionBalance)
         income.title
            .text(Design.text.personalBalance)
      }
      .spacing(35)
      .alignment(.center)
      .height(Grid.x90.value)
      .backColor(Design.color.backgroundBrandSecondary)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)
      .padding(Design.params.infoFramePadding)
      .clipsToBound(true)
//      .backViewModel(ChostBackLogo<Design>(size: 104)
//         .padding(.shift(.init(x: 150.aspected, y: 0)))
//         .setup {
//            $0.logo.backColor(.black)
//         }
//         .alpha(0.2)
//      )
      .hidden(true)
   
}

final class BalanceInfoBlock<Design: DSP>: Stack<LabelModel>.D<LabelModel>.R<StackModel>.Ninja {
   var title: LabelModel { models.main }
   var amount: LabelModel { models.down }
   var currencyStack: StackModel { models.right }
   
   var currency: LabelModel = LabelModel()
      .padLeft(6)
      .text(Design.text.defaultCurrency)
      .font(Design.font.descriptionRegular12)
      .textColor(Design.color.text)
   
   required init() {
      super.init()

      setAll { header, amount, currencyStack in
         header
            .font(Design.font.descriptionRegular12)
            .textColor(Design.color.text)
         amount
            .font(Design.font.descriptionBold36)
            .textColor(Design.color.text)
         currencyStack
            .arrangedModels([
               Grid.xxx.spacer,
               currency
            ])
      }
      alignment(.leading)
      spacing(6)
   }
   
   func setAmount(_ value: Int) {
      amount.text(String(value))
      currency.text(Design.text.pluralCurrencyForValue(value, case: .genitive))
   }
}
