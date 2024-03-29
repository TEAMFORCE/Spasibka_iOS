//
//  MainMenuSceneViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 07.02.2024.
//

import Foundation
import StackNinja

final class MainMenuSceneViewModel<Asset: ASP>: VStackModel, Scenarible, Assetable, Eventable {
   typealias Events = MainSceneEvents<UserData?>

   var events = EventsStore()

   lazy var scenario = MainMenuScenario(
      works: MainMenuWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: MainMenuScenarioInputEvents(
         reloadNewNotifies: Work.void,
         presentHistoryScene: Work.void,
         presentFeedScene: Work.void,
         didSelectFeedItemAtIndex: eventsSegment.on(\.didTapButtonIndex),
         didSelectRecItemAtIndex: recommendationsSegment.on(\.didTapButtonIndex)
      )
   )

   private lazy var userDataNotFilledPopup = DialogPopupVM<Design>()
   private(set) lazy var bottomPopupPresenter = BottomPopupPresenter()
   
   private lazy var errorBlock = Design.model.common.connectionErrorBlock
   private lazy var activityIndicator = Design.model.common.activityIndicatorSpaced

   private(set) lazy var headerViewModel = CustomTopbarViewModel<Asset>()

   private lazy var pagesSegment = ScrollableSegmentControl<Design>()
      .set(.padding(.horizontalOffset(16)))
      .backColor(Design.color.background)
      .setStates(.buttons([
         participantsButton,
         awardsButton,
         historyButton
      ]))
   
   private lazy var pagesStack = StackModel()
      .axis(.horizontal)
      .alignment(.center)
      .spacing(8)
      .arrangedModels(participantsButton, awardsButton, historyButton)
      .padding(.init(top: 8, left: 16, bottom: 8, right: 16))
      .distribution(.equalCentering)

   private lazy var eventsSegment = ScrollableSegmentControl<Design>()
      .set(.padding(.horizontalOffset(16)))
      .backColor(Design.color.background)

   private lazy var recommendationsSegment = ScrollableSegmentControl<Design>()
      .backColor(Design.color.background)

   private lazy var participantsButton = PageButtonModel<Design>()
      .setAll { label, image in
         label
            .alignment(.right)
            .set(Design.state.label.regular12)
            .numberOfLines(1)
         
         image
            .size(.init(width: 74, height: 63))
            .contentMode(.scaleAspectFit)
            .backColor(Design.color.background)
      }
      .setStates(
         .text(Design.text.participants),
         .image(Design.icon.participantsIcon)
      )
      .on(\.didTap) {
         Asset.router?.route(.push, scene: \.employees)
      }

   private lazy var historyButton = PageButtonModel<Design>()
      .setAll { label, image in
         label
            .alignment(.right)
            .set(Design.state.label.regular12)
            .numberOfLines(1)
         
         image
            .size(.init(width: 96, height: 50))
            .contentMode(.scaleAspectFill)
            .backColor(Design.color.background)
      }
      .setStates(
         .text(Design.text.history),
         .image(Design.icon.historyIcon)
      )
      .on(\.didTap) {
         self.scenario.events.presentHistoryScene.doAsync()
      }

   private lazy var awardsButton = PageButtonModel<Design>()
      .setAll { label, image in
         label
            .alignment(.right)
            .set(Design.state.label.regular12)
            .numberOfLines(1)
         
         image
            .size(.init(width: 67, height: 58))
            .contentMode(.scaleAspectFit)
            .backColor(Design.color.background)
      }
      .setStates(
         .text(Design.text.awards),
         .image(Design.icon.rewardsIcon)
      )
      .on(\.didTap) {
         Asset.router?.route(.push, scene: \.awards)
      }

   private lazy var feedLabel = Design.label.descriptionMedium14
      .text(Design.text.news)
      .backColor(Design.color.background)

   private lazy var allFeedLabel = Design.label.descriptionMedium14
      .text(Design.text.all1)
      .textColor(Design.color.textInfo)
      .makeTappable()
      .backColor(Design.color.background)
      .makeTappable()
      .on(\.didTap) {
         self.scenario.events.presentFeedScene.doAsync()
      }

   private lazy var recommendationLabel = Design.label.descriptionMedium14
      .text(Design.text.recommend)
      .backColor(Design.color.background)

   private lazy var feedLabelsStack = StackModel()
      .axis(.horizontal)
      .alignment(.leading)
      .distribution(.fill)
      .arrangedModels([
         feedLabel,
         Spacer(),
         allFeedLabel
      ])
      .backColor(Design.color.background)

   private(set) lazy var scrollWrapper = ScrollStackedModelY()
      .disableScroll()
      .bounces(false)
      .arrangedModels(
         pagesStack,
//         Spacer()
//         pagesSegment,
         Spacer(16),
         feedLabelsStack.padHorizontal(16),
         Spacer(12),
         eventsSegment,
         Spacer(12),
         recommendationLabel.padLeft(16),
         Spacer(12),
         recommendationsSegment,
         Spacer(150)
      )

      .hideVerticalScrollIndicator()

   override func start() {
      super.start()

      backColor(Design.color.background)
//      arrangedModels(
//         headerViewModel,
//         scrollWrapper
//      )

      pagesSegment.on(\.didTapButtonIndex) { index in
         switch index {
         case 0:
            Asset.router?.route(.push, scene: \.employees)
         case 1:
            Asset.router?.route(.push, scene: \.awards)
         case 2:
            self.scenario.events.presentHistoryScene.doAsync()
         case 3:
            break
         default:
            break
         }
      }

      addModel(errorBlock, setup: {
         $0.fitToTop($1)
      })

      //      vcModel?.on(\.viewWillAppearByBackButton, self) {
      //         $0.scenario.events.reloadNewNotifies.doAsync()
      //      }


      setState(.initial)

      scenario.events.reloadNewNotifies.doAsync()
   }
   
   func reloadNotificationsAmount() {
      scenario.events.reloadNewNotifies.doAsync()
   }
}

enum MainMenuSceneState {
   case initial
   case balanceDidLoad(Balance)
   case loadBalanceError
   case setUserProfileInfo(String, String?)
   case updateAlarmButtonWithNewNotificationsCount(Int)
   case presentHistoryScene(UserData)
   case presentFeedScene(UserData)
   case presentFeedSegment([FeedEvent])
   case presentRecommendationSegment([Recommendation])
   case routeToEvent(FeedEvent, Bool? = nil)
   case routeToLink(URL, Bool? = nil)
   case routeToRecommendation(Recommendation)
   case loadProfileError
   case presentUserDataNotFilledPopup
}

extension MainMenuSceneViewModel: StateMachine {
   func setState(_ state: MainMenuSceneState) {
      switch state {
      case .initial:
         errorBlock.hidden(true)
         activityIndicator.hidden(false)
      case let .balanceDidLoad(balance):
         errorBlock.hidden(true)
         activityIndicator.hidden(true)
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd"
         var diffs = 0
         if let date1 = dateFormatter.date(from: balance.distr.expireDate.unwrap) {
            let date2 = Date()
            diffs = Calendar.current.numberOf24DaysBetween(date2, and: date1)
         }
         headerViewModel.setData(
            leftToShare: balance.distr.amount,
            yourBalance: balance.income.amount,
            remainingDays: diffs
         )
      case .loadBalanceError:
         errorBlock.hidden(false)
         activityIndicator.hidden(true)
      case let .setUserProfileInfo(name, imageUrl):
         headerViewModel.setUsername(name)
         if let url = imageUrl {
            headerViewModel.setAvatarFromUrl(SpasibkaEndpoints.urlBase + url)
         }
      case let .updateAlarmButtonWithNewNotificationsCount(amount):
         headerViewModel.setNotificationsCount(amount)
      case let .presentHistoryScene(currentUser):
         Asset.router?.route(
            .push,
            scene: \.history,
            payload: currentUser
         )
      case let .presentFeedScene(currentUser):
         Asset.router?.route(
            .push,
            scene: \.feed,
            payload: currentUser
         )
      case let .presentFeedSegment(events):
         var eventButtons: [EventButtonModel<Design>] = []
         for event in events {
            eventButtons.append(EventButtonModel<Design>().setStates(.setValues(event)))
         }
         eventsSegment.setState(.buttons(eventButtons))
         eventsSegment.spacing(8)
      case let .presentRecommendationSegment(recommendations):
         var recButtons: [RecommendationCell<Design>] = []
         for rec in recommendations {
            var imageUrl: String?
            if let url = rec.photos?.first {
               imageUrl = SpasibkaEndpoints.urlBase + url
            }
            let button = RecommendationCell<Design>()
            button.setStates(
               .imageUrl(imageUrl),
               .title(rec.header.unwrap),
               .author(rec.name.unwrap),
               .isNew(rec.isNew)
            )

            recButtons.append(button)
         }
         recommendationsSegment.setState(.buttons(recButtons))
         recommendationsSegment.set(.padding(.init(top: 8, left: 16, bottom: 8, right: 16)))
         recommendationsSegment.spacing(11)
      case let .routeToEvent(event, isComment):
         switch event.eventSelectorType {
         case .challenge:
            var chapter = ChallengeDetailsInput.Chapter.details
            if isComment == true { chapter = .comments }
            let id = event.id
            let input = ChallengeDetailsInput.byId(id, chapter: chapter)
            Asset.router?.route(.push, scene: \.challengeDetails, payload: input)
         case .transaction:
            let id = event.id
            let input = TransactDetailsSceneInput.transactId(id, isComment)
            Asset.router?.route(.push, scene: \.transactDetails, payload: input)
         case .winner:
            let id = event.id
            let input = ContenderDetailsSceneInput.winnerReportId(id, isComment)
            Asset.router?.route(
               .push,
               scene: \.challengeContenderDetail,
               payload: input,
               finishWork: nil
            )
         case .market:
            let id = event.id
            Asset.router?.route(.push, scene: \.benefitDetails, payload: (id, .init(id: id, name: "")))
         case .none:
            break
         }
      case let .routeToLink(url, isComment):
         Asset.router?.routeLink(url, navType: .push, isComment: isComment)
      case let .routeToRecommendation(recommendation):
         switch recommendation.type {
         case .challenge:
            let chapter = ChallengeDetailsInput.Chapter.details
            guard let id = recommendation.id else { break }
            let input = ChallengeDetailsInput.byId(id, chapter: chapter)
            Asset.router?.route(.push, scene: \.challengeDetails, payload: input)
         case .questionnaire:
            break
         case .offer:
            guard
               let id = recommendation.id,
               let marketId = recommendation.marketplaceId
            else {
               break
            }
            let payload = (id, Market(id: marketId, name: ""))
            Asset.router?.route(
               .push,
               scene: \.benefitDetails,
               payload: payload
            )
         case .chain:
            guard let id = recommendation.id else { break }
            Asset.router?.route(
               .push,
               scene: \.chainDetails,
               payload: .byId(id, chapter: .details)
            )
         case .none:
            break
         }
      case .loadProfileError:
//         mainVM.setState(.presentErrorModel(errorBlock))
         errorBlock.hidden(false)
      case .presentUserDataNotFilledPopup:
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }

            self.userDataNotFilledPopup.setState(
               .init(
                  image: Design.icon.smartPeopleIllustrate,
                  title: Design.text.noUserDataWarning,
                  subtitle: nil,
                  buttonText: Design.text.goToSettings,
                  buttonSecondaryText: Design.text.cancel
               )
            )
            self.bottomPopupPresenter.setState(.presentWithAutoHeight(
               model: self.userDataNotFilledPopup,
               onView: self.view.superview //self.vcModel?.superview
            ))
            self.userDataNotFilledPopup.didTapButtonWork
               .onSuccess(self) {
                  $0.bottomPopupPresenter.setState(.hide)
                  Asset.router?.route(.push, scene: \.myProfile)
               }
            self.userDataNotFilledPopup.didTapCancelButtonWork
               .onSuccess(self.bottomPopupPresenter) {
                  $0.setState(.hide)
               }
         }
      }
   }
}
