//
//  BenefitBasketScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja

struct BenefitBasketSceneParams<Asset: AssetProtocol>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Market
      typealias Output = Void
   }
}

final class BenefitBasketScene<Asset: ASP>: BaseParamsScene<BenefitBasketSceneParams<Asset>>, Scenarible {
   lazy var scenario = BenefitBasketScenario(
      works: BenefitBasketWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: BenefitBasketScenarioScenarioInput(
         saveInput: on(\.input),
         deleteItemPressed: viewModel.eventer.on(\.deletePressed),
         countPlussPressed: viewModel.eventer.on(\.countPlusPressed),
         countMinusPressed: viewModel.eventer.on(\.countMinusPressed),
         checkMarkPressed: viewModel.eventer.on(\.checkMarkSelected),

         tableItemPressed: viewModel.benefitList.on(\.didSelectItemAtIndex),
         buyButtonPressed: buyButton.on(\.didTap),

         confirmDelete: Work.void,
         cancelDelete: Work.void
      )
   )

   private lazy var viewModel = BenefitBasketVM<Design>()

   private lazy var buyButton = Design.button.default
      .set(Design.state.button.inactive)
      .addModel(buttonContent) { anchors, superview in
         anchors
            .centerX(superview.centerXAnchor)
            .centerY(superview.centerYAnchor)
      }
   
   private lazy var buyLabel = LabelModel()
      .font(Design.font.descriptionMedium16)
      .text(Design.text.payButton)
      .textColor(Design.color.textInvert)
   
   private lazy var buttonContent = StackModel()
      .axis(.horizontal)
      .spacing(10)
      .arrangedModels([
         buyLabel,
         priceModel
      ])
   
   private lazy var priceModel = NewCurrencyLabelDT<Design>()
      .setAll { image, _, label in
         label
            .font(Design.font.descriptionMedium18)
            .textColor(Design.color.textInvert)
            .text("0")
         image
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.iconInvert)
            .size(.init(width: 17.45, height: 14))
      }
      .height(24)
      .spacing(2.5)

   private lazy var activityModel = Design.model.common.activityIndicatorSpaced
   private lazy var hereIsEmptySpaced = Design.model.common.hereIsEmptySpaced
   private lazy var errorModel = Design.model.common.connectionErrorBlock
      .backColor(Design.color.background)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusBig)
      .padTop(8)
      .padBottom(24)

   private lazy var bottomPresenter = BottomPopupPresenter()
   private lazy var alertPresenter = CenterPopupPresenter()
   private lazy var darkLoaderVM = DarkLoaderVM<Design>()

   private lazy var benefitBuySuccessVM = BenefitBuySuccessVM<Asset>()

   override func start() {
      super.start()

      mainVM.navBar
         .titleLabel.text(Design.text.cart)
      mainVM.navBar.menuButton.image(nil)

      mainVM.bodyStack.arrangedModels(
         activityModel,
         hereIsEmptySpaced.hidden(true),
         errorModel.hidden(true),
         viewModel.hidden(true)
      )

      mainVM.footerStack.arrangedModels(
         buyButton
      )

      scenario.configureAndStart()

      vcModel?.on(\.viewWillAppearByBackButton, self) {
         $0.scenario.sendStartEvent()
      }
   }
}

enum BenefitBasketState {
   case initial

   case presentBasketItems([CartItem])
   case presentBenefitDetails((Int, Market))

   case updateSummaAndButton([CartItem])
   case updateItemAtIndex(CartItem, Int)

   case presentLoadingError
   case presentHereIsEmpty

   case deleteItemError
   case connectionError

   case presentFullScreenDarkLoader
   case hideFullScreenDarkLoader

   case finishBuyOffers
   case presenBuyError

   case presentDeleteAlert
}

extension BenefitBasketScene: StateMachine {
   func setState(_ state: BenefitBasketState) {
      switch state {
      case .initial:
         break
      //
      case let .presentBasketItems(items):
         if items.isEmpty {
            setState(.presentHereIsEmpty)
         } else {
            activityModel.hidden(true)
            errorModel.hidden(true)
            hereIsEmptySpaced.hidden(true)
            viewModel.hidden(false)
            viewModel.benefitList.items(items)
         }
         setState(.updateSummaAndButton(items))
      //
      case .presentHereIsEmpty:
         activityModel.hidden(true)
         viewModel.hidden(true)
         errorModel.hidden(true)
         hereIsEmptySpaced.hidden(false)
      //
      case .presentLoadingError:
         activityModel.hidden(true)
         viewModel.hidden(true)
         errorModel.hidden(false)
         hereIsEmptySpaced.hidden(true)
      //
      case .deleteItemError:
         viewModel.benefitList.reload()
      //
      case let .updateItemAtIndex(item, index):
         viewModel.benefitList.updateItemAtIndex(item, index: index)
      //
      case .connectionError:
         bottomPresenter.setState(.presentWithAutoHeightForTime(model: errorModel,
                                                                onView: vcModel?.view.superview,
                                                                duration: 1.5))
      //
      case let .updateSummaAndButton(items):
         var someChecked = false
         let sum = items.reduce(into: 0) { partialResult, item in
            if !someChecked, item.isChosen == true { someChecked = true }
            return partialResult += item.isChosen == true ? (item.price ?? 0) * (item.quantity ?? 0) : 0
         }
         priceModel.label.text(String(sum))
         if someChecked {
            buyButton.set(Design.state.button.default)
         } else {
            buyButton.set(Design.state.button.inactive)
         }
      //
      case let .presentBenefitDetails(value):
         Asset.router?.route(
            .push,
            scene: \.benefitDetails,
            payload: value
         )
      //
      case .presentFullScreenDarkLoader:
         darkLoaderVM.setState(.loading(onView: vcModel?.view.superview))
      //
      case .hideFullScreenDarkLoader:
         darkLoaderVM.setState(.hide)
      //
      case .finishBuyOffers:
         bottomPresenter.setState(.present(model: benefitBuySuccessVM,
                                           onView: vcModel?.view.superview))
         bottomPresenter.on(\.hide) {
            Asset.router?.popToRoot()
         }
      //
      case .presenBuyError:
         setState(.hideFullScreenDarkLoader)
         setState(.presentLoadingError)
      //
      case .presentDeleteAlert:
         let alert = AlertViewModel<Design>(title: Design.text.removeFromCart, buttons:
            AlertDefaultButton<Design>(text: Design.text.no).on(\.didTap, self) {
               $0.scenario.events.cancelDelete.doAsync()
               $0.alertPresenter.setState(.hide)
            },
            AlertDefaultButton<Design>(text: Design.text.yes).on(\.didTap, self) {
               $0.scenario.events.confirmDelete.doAsync()
               $0.alertPresenter.setState(.hide)
            })
         alertPresenter.setState(.present(model: alert, onView: vcModel?.view.superview))
      }
   }
}

struct AlertViewEvent: InitProtocol {
   var dismissed: Void?
}

class AlertViewModel<Design: DSP>: Stack<LabelModel>.D<Spacer>.D2<HStackModel>.Ninja, Eventable {
   typealias Events = AlertViewEvent

   var events: EventsStore = .init()

   private lazy var buttons: [ButtonModel] = []

   convenience init(title: String, buttons: ButtonModel...) {
      self.init()

      setAll { label, _, buttonStack in
         label
            .set(Design.state.label.regular14)
            .text(title)
         buttonStack
            .spacing(12)
            .arrangedModels([Spacer()] + buttons)
      }
      .padding(.init(top: 24, left: 24, bottom: 8, right: 12))
      .size(.init(width: 280, height: 124))
      .backColor(Design.color.background)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)

      self.buttons = buttons

      view.on(\.willDisappear, self) {
         $0.send(\.dismissed)
      }
   }
}

final class AlertDefaultButton<Design: DSP>: ButtonModel {
   convenience init(text: String) {
      self.init()

      title(text)
      font(Design.font.medium14)
      textColor(Design.color.textBrand)
      height(36)
   }
}
