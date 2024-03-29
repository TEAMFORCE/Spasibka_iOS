//
//  Asset.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.06.2022.
//

import StackNinja
import UIKit

enum ProductionAsset: AssetProtocol {
   typealias Router = MainRouter<ProductionAsset>
   typealias Text = Texts
   typealias Design = DesignSystem
   typealias Service = ProductionService
   typealias Scene = Scenes

   weak static var router: MainRouter<ProductionAsset>?
}

private typealias PA = ProductionAsset

protocol ScenesProtocol: InitProtocol {}

extension ScenesProtocol {
   var tabBar: BaseScene<TabBarSceneInput?, Void> { TabBarScene<PA>() }
   var balance: BaseScene<Void, Void> { BalanceScene<PA>() }
   var transactions: BaseScene<TransactSceneInput?, Void> { TransactScene<PA>() }
   //
   var onboarding: BaseScene<String, Void> { OnboardingScene<PA>() }
   var onboarding2: BaseScene<String, Void> { Onboarding2Scene<PA>() }
   var onboardingFinal: BaseScene<(name: String, sharingKey: String), Void> { OnboardingFinalScene<PA>() }
   //
   var animationIntro: BaseScene<Void, Void> { AnimatedIntroScene<PA>() }
   var digitalThanks: BaseScene<Void, Void> { DigitalThanksScene<PA>() }
   //
   var login: BaseScene<LoginInput, Void> { LoginScene<PA>() }
   var verify: BaseScene<VerifySceneInput, Void> { VerifyScene<PA>() }
   var chooseOrgScene: BaseScene<ChooseOrgSceneInput, Void> { ChooseOrgScene<PA>() }
   var organizations: BaseScene<[Organization], Void> { OrganizationsScene<PA>() }
   var createOrganization: BaseScene<CommunityParams, CommunityParams> { CreateOrganizationScene<PA>() }
   //
//   var main: BaseScene<MainSceneInput, Void> { MainScene<PA>() }
   //
   var myProfile: BaseScene<ProfileID, UIImage> { MyProfileScene<PA>() }
   var profile: BaseScene<ProfileID, Void> { UserProfileScene<PA>() }
   var userStatusSelector: BaseScene<StatusSelectorInput, UserStatus> { StatusSelectorScene<PA>() }
   var editMyContacts: BaseScene<EditContactsInOut.Input, EditContactsInOut.Output> {
      EditContactsScene<PA>()
   }

   var editMyLocation: BaseScene<Void, Void> { EditLocationScene<PA>() }
   //
   var transactDetails: BaseScene<TransactDetailsSceneInput, Void> { TransactDetailsScene<PA>() }
   var sentTransactDetails: BaseScene<Transaction, Void> { SentTransactDetailsScene<PA>() }
   //
   var challengesGroup: BaseScene<Void, Void> { ChalengeGroupScene<PA>() }
   var challengesMenu: BaseScene<Void, Void> { ChallengeMenuScene<PA>() }
   var challengeDetails: BaseScene<ChallengeDetailsInput, Void> { ChallengeDetailsScene<PA>() }
   var challengeCreate: BaseScene<ChallengeCreateInput, FinishEditChallengeEvent> { ChallengeCreateScene<PA>() }
   var challengeSendResult: BaseScene<Int, Void> { ChallengeResultScene<PA>() }
   var challengeResCancel: BaseScene<Int, Void> { ChallengeResCancelScene<PA>() }
   var challengeReportDetail: BaseScene<Int, Void> { ChallReportDetailsScene<PA>() }
   var challengeSettings: BaseScene<ChallengeSettings, Void> {
      ChallengeSettingsScene<PA>()
   }
   var challengeComments: BaseScene<Challenge, Void> { ChallengeCommentsScene<PA>() }
   var challengeResults: BaseScene<ChallengeDetailsInput, Void> { ChallengeResultsScene<PA>() }
   var challengeReactions: BaseScene<ReactionsSceneInput, Void> { ChallengeReactionsScene<PA>() }

   var challengeTemplates: BaseScene<Void, Void> { ChallengeTemplatesScene<PA>() }

   var challengeContenderDetail: BaseScene<ContenderDetailsSceneInput, Void> { ContenderDetailsScene<PA>() }
   // var challengeTemplates: BaseScene<Void, Void> { ChallengeTemplatesSceneOld<PA>() }
   var createChallengeTemplate: BaseScene<ChallengeTemplateCreateInput, Void> { ChallengeTemplateCreateScene<PA>() }

   var categories: BaseScene<CategoriesInput, [CategoryData]> { CategoriesScene<PA>() }
   var categoriesEdit: BaseScene<CategoriesEditInput, Void> { CategoriesEditScene<PA>() }
   //
   var notifications: BaseScene<Void, Void> { NotificationsScene<PA>() }
   //
   var settings: BaseScene<UserData, Void> { SettingsScene<PA>() }
   //
   var imageViewer: BaseScene<ImageViewerInput, Void> { ImageViewerScene<PA>() }

   //
   var pdfViewer: BaseScene<(title: String, pdfName: String), Void> { PrivacyPolicyScene<PA>() }
   var about: BaseScene<Void, Void> { AboutScene<PA>() }
   var feedback: BaseScene<Void, Void> { FeedbackScene<PA>() }
   var language: BaseScene<Void, Void> { LanguageScene<PA>() }

   //
   var playground: BaseScene<Void, Void> { PlaygroundScene<PA>() }

   //
   var market: BaseScene<Void, Void> { MarketScene<PA>() }
   var benefitDetails: BaseScene<(Int, Market), Void> { BenefitDetailsScene<PA>() }
   var benefitBasket: BaseScene<Market, Void> { BenefitBasketScene<PA>() }
   var benefitsPurchaseHistory: BaseScene<Market, Void> { BenefitsPurchaseHistoryScene<PA>() }

   var loginVK: BaseScene<LoginVKSceneInput, Void> { LoginVKScene<PA>() }

   var challenges: BaseScene<Void, Void> { ChallengesScene<PA>() }
   var challengeChains: BaseScene<Void, Void> { ChallengeChainsScene<PA>() }
   var challengeChainSteps: BaseScene<ChallengeGroup, Void> { ChainStepsScene<PA>() }
   var chainParticipantsScene: BaseScene<ChallengeGroup, Void> { ChainParticipantsScene<PA>() }
   var chainDetails: BaseScene<ChainDetailsInput, Void> { ChainDetailsScene<PA>() }

   var employees: BaseScene<Void, Void> { EmployeesScene<PA>() }
   var history: BaseScene<UserData, Void> { HistoryScene<PA>() }
   var feed: BaseScene<UserData, Void> { FeedScene<PA>() }

   var awards: BaseScene<Void, Void> { AwardsScene<PA>() }
   var awardDetails: BaseScene<Award, Void> { AwardDetailsScene<PA>() }

   var mainMenu: BaseScene<Void, Void> { MainMenuScene<PA>() }
}

struct Scenes: ScenesProtocol {}

struct ProductionService: ServiceProtocol {
   var apiEngine: ApiEngineProtocol { ApiEngine() }
   var apiWorks: ApiWorksProtocol { ApiWorks() }
   var safeStringStorage: StringStorageProtocol { KeyChainStore() }
   var userDefaultsStorage: UserDefaultsStorageProtocol { UserDefaults() }
   var staticTextCache: StaticTextCacheProtocol.Type { StaticTextCache.self }
}

struct MockService: ServiceProtocol {
   var apiEngine: ApiEngineProtocol { ApiEngine() }
   var apiWorks: ApiWorksProtocol { ApiWorks() }
   var safeStringStorage: StringStorageProtocol { MockKeyChainStore() }
   var userDefaultsStorage: UserDefaultsStorageProtocol { UserDefaults() }
   var staticTextCache: StaticTextCacheProtocol.Type { StaticTextCache.self }
}

enum MockAsset: AssetProtocol {
   typealias Router = MainRouter<MockAsset>
   typealias Text = Texts
   typealias Design = DesignSystem
   typealias Service = MockService
   typealias Scene = Scenes

   weak static var router: MainRouter<MockAsset>?
}
