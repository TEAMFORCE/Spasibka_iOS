//
//  Texts.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.06.2022.
//

import Foundation
import StackNinja

// MARK: - Texts

protocol TextsProtocol: InitProtocol {}

// MARK: - Texts implements

extension TextsProtocol {
   var onboardingTitle: String { "onboardingTitle".localized() }
   var createCommunity: String { "createCommunity".localized() }
   var connectToCommunity: String { "connectToCommunity".localized() }
   var step: String { "step".localized() }
   var `continue`: String { "continue".localized() }
   var communities: String { "communities".localized() }
   var createCommunityDescription: String { "createCommunityDescription".localized() }
   var fillCommunityInformation: String { "fillCommunityInformation".localized() }
   var title: String { "title".localized() }
   var invitationCode: String { "invitationCode".localized() }
   var invitationLink: String { "invitationLink".localized() }
   var code: String { "code".localized() }
   var periodSettings: String { "periodSettings".localized() }
   var periodStartDate: String { "periodStartDate".localized() }
   var periodEndDate: String { "periodEndDate".localized() }
   var start: String { "start".localized() }
   var manualConfig: String { "manualConfig".localized() }
   var automaticConfig: String { "automaticConfig".localized() }
   var startWithStandard: String { "startWithStandard".localized() }
   var congrats: String { "congrats".localized() }
   var siteConfigComplete: String { "siteConfigComplete".localized() }
   var goToMainScreen: String { "goToMainScreen".localized() }
   var learningMaterials: String { "learningMaterials".localized() }
   var noCommunityToStartPeriod: String { "noCommunityToStartPeriod".localized() }
   var joinOrCreateCommunity: String { "joinOrCreateCommunity".localized() }
   var backToCommunities: String { "backToCommunities".localized() }
   var inviteMembersToCommunity: String { "inviteMembersToCommunity".localized() }
   var inviteMembers: String { "inviteMembers".localized() }
   var communityCreated: String { "communityCreated".localized() }

   var enterButton: String { "enterButton".localized() }
   var nextButton: String { "nextButton".localized() }
   var registerButton: String { "registerButton".localized() }
   var getCodeButton: String { "getCodeButton".localized() }
   var changeUserButton: String { "changeUserButton".localized() }
   var sendButton: String { "sendButton".localized() }
   var toTheBeginingButton: String { "toTheBeginingButton".localized() }
   var logoutButton: String { "logoutButton".localized() }

   var closeButton: String { "closeButton".localized() }
   var thankButton: String { "thankButton".localized() }

   var sendTransactionAgain: String { "sendTransactionAgain".localized() }

   var getButton: String { "getButton".localized() }
   var toMain: String { "toMain".localized() }
   var addButton: String { "addButton".localized() }
   var addToCart: String { "addToCart".localized() }
   var inCartButton: String { "inCartButton".localized() }
   var payButton: String { "payButton".localized() }

   var details: String { "details".localized() }
   var comments: String { "comments".localized() }
   var reactions: String { "reactions".localized() }
   var like: String { "like".localized() }
   var edited: String { "edited".localized() }

   var allHistory: String { "allHistory".localized() }
   var received: String { "received".localized() }
   var sent: String { "sent".localized() }
   var groupByUser: String { "groupByUser".localized() }
   var transfer: String { "transfer".localized() }
   var transferVerb: String { "transferVerb".localized() }
   var purchaseBenefit: String { "purchaseBenefit".localized() }
   var refund: String { "refund".localized() }
   var benefits: String { "benefits".localized() }

   var createChallenge: String { "createChallenge".localized() }
   var сhallengeTemplates: String { "challengeTemplates".localized() }
   var newTemplate: String { "newTemplate".localized() }
   var editTemplate: String { "editTemplate".localized() }
   var searchByTemplates: String { "searchByTemplates".localized() }
   var my: String { "my".localized() }
   var ours: String { "ours".localized() }
   var common: String { "common".localized() }
   var delayedStart: String { "delayedStart".localized() }
   var changeFond: String { "changeFond".localized() }

   var activeChallenges: String { "activeChallenges".localized() }
   var deferredChallenges: String { "deferredChallenges".localized() }

   var myResult: String { "myResult".localized() }
   var candidates: String { "candidates".localized() }
   var winners: String { "winners".localized() }
   var participants: String { "participants".localized() }
   var participants2: String { "participants2".localized() }

   var sendResult: String { "sendResult".localized() }

   var reject: String { "reject".localized() }
   var confirm: String { "confirm".localized() }

   var cancel: String { "cancel".localized() }

   var create: String { "create".localized() }

   var save: String { "save".localized() }

   var addPhoto: String { "addPhoto".localized() }
   var addSticker: String { "addSticker".localized() }
   var selectPhoto: String { "selectPhoto".localized() }
   var takePhoto: String { "takePhoto".localized() }

   var autorisation: String { "autorisation".localized() }
   var digitalThanks: String { "digitalThanks".localized() }
   var digitalThanksAbout: String { "digitalThanksAbout".localized() }
   var enter: String { "enter".localized() }
   var register: String { "register".localized() }
   var enterTelegramName: String { "enterTelegramName".localized() }
   var enterSmsCode: String { "enterSmsCode".localized() }
   var pressGetCode: String { "pressGetCode".localized() }
   var userName: String { "userName".localized() }
   var userNameDescription: String { "userNameDescription".localized() }
   var smsCode: String { "smsCode".localized() }
   var loginSuccess: String { "loginSuccess".localized() }

   // balance
   var selectPeriod: String { "selectPeriod".localized() }
   var myAccount: String { "myAccount".localized() }
   var leftToSend: String { "leftToSend".localized() }
   var onAgreement: String { "onAgreement".localized() }
   var canceled: String { "canceled".localized() }
   var sended: String { "sended".localized() }
   var day: String { "day".localized() }
   var days: String { "days".localized() }
   var days1: String { "days1".localized() }
   var new: String { "new".localized() }
   var historyOfTransactions: String { "historyOfTransactions".localized() }
   var distributionBalance: String { "distributionBalance".localized() }
   var personalBalance: String { "personalBalance".localized() }
   var defaultCurrency: String { "defaultCurrency".localized() }
   
   //mainMenu
   var yourBalance: String { "yourBalance".localized() }
   var remainingDayText: String { "remainingDayText".localized() }

   // transact
   var newTransact: String { "newTransact".localized() }
   var close: String { "close".localized() }
   var chooseRecipient: String { "chooseRecipient".localized() }
   var availableCurrency: String { "availableThanks".localized() }
   var reasonPlaceholder: String { "reasonPlaceholder".localized() }
   var recipient: String { "recipient".localized() }
   var userNotFound: String { "userNotFound".localized() }
   var thanks: String { "thanks".localized() }
   var transactStatusLabel: String { "transactStatusLabel".localized() }
   var date: String { "date".localized() }
   var time: String { "time".localized() }
   var toWhom: String { "toWhom".localized() }
   var amount: String { "amount".localized() }
   var inProcess: String { "inProcess".localized() }
   
   // errors
   var wrongUsername: String { "wrongUsername".localized() }
   var wrongCode: String { "wrongCode".localized() }
   var loadPageError: String { "loadPageError".localized() }
   var connectionError: String { "connectionError".localized() }
   var notFoundEror: String { "notFoundError".localized() }

   // verifyScene
   var noCode: String { "noCode".localized() }
   var messageEmail: String { "messageEmail".localized() }
   var messageTelegram: String { "messageTelegram".localized() }

   // historyScene
   var today: String { "today".localized() }
   var yesterday: String { "yesterday".localized() }
   var cancelTransferQuestion: String { "cancelTransferQuestion".localized() }
   // feed deatail
   var comment: String { "comment".localized() }

   // benefitBasketScene
   var total: String { "total".localized() }
   var cart: String { "cart".localized() }
   var removeFromCart: String { "removeFromCart".localized() }
   var yes: String { "yes".localized() }
   var yesLowercase: String { "yesLowercase".localized() }
   var no: String { "no".localized() }
   var noLowercase: String { "noLowercase".localized() }
   var validUntil: String { "validUntil".localized() }
   var delete: String { "delete".localized() }
   var edit: String { "edit".localized() }

   // EmployeesScene
   var findEmployee: String { "findEmployee".localized() }
   var search: String { "search".localized() }
   var firedAt: String { "firedAt".localized() }
   var inOffice: String { "inOffice".localized() }
   var onHoliday: String { "onHoliday".localized() }
   var subdivision: String { "subdivision".localized() }
   var searchProduct: String { "searchProduct".localized() }

   // benefitBuySuccessVM
   var successfulOrder: String { "successfulOrder".localized() }

   // BenefitDetailScene
   var benefit: String { "benefit".localized() }
   var select: String { "select".localized() }
   var units: String { "units".localized() }
   var leftAmount: String { "leftAmount".localized() }
   var selectedAmount: String { "selectedAmount".localized() }
   var restAmount: String { "restAmount".localized() }
   var limitForPeriod: String { "limitForPeriod".localized() }

   // BenefitInfoVM
   var validity: String { "validity".localized() }
   var description: String { "description".localized() }
   var price: String { "price".localized() }
   var notLimited: String { "notLimited".localized() }

   // BenefitPurchaseHistory
   var orderHistory: String { "orderHistory".localized() }
   var processed: String { "processed".localized() }
   var status: String { "status".localized() }

   // OrderStatusFactory
   var ordered: String { "ordered".localized() }
   var acceptedWaiting: String { "acceptedWaiting".localized() }
   var acceptedByCustomer: String { "acceptedByCustomer".localized() }
   var purchased: String { "purchased".localized() }
   var readyForDelivery: String { "readyForDelivery".localized() }
   var sentOrDelivered: String { "sentOrDelivered".localized() }
   var ready: String { "ready".localized() }
   var `repeat`: String { "repeat".localized() }
   var declined: String { "declined".localized() }
   var cancelled: String { "cancelled".localized() }

   // MarketFilterScene
   var education: String { "education".localized() }
   var travelAndLeisure: String { "travelAndLeisure".localized() }
   var health: String { "health".localized() }
   var from: String { "from".localized() }
   var to: String { "to".localized() }
   var expires: String { "expires".localized() }

   var category: String { "category".localized() }
   var categories: String { "categories".localized() }
   var categoriesDescription: String { "categoriesDescription".localized() }
   var categoriesEdit: String { "categoriesEdit".localized() }
   var createCategory: String { "createCategory".localized() }
   var parentCategories: String { "parentCategories".localized() }
   var categoryName: String { "categoryName".localized() }

   var price1: String { "price1".localized() }
   var travel: String { "travel".localized() }
   var leisure: String { "leisure".localized() }
   var all: String { "all".localized() }
   
   var inLowercase: String { "inLowercase".localized() }

   // AboutScene
   var region: String { "region".localized() }
   var searchingInProgress: String { "searchingInProgress".localized() }
   var aboutTheApp: String { "aboutTheApp".localized() }
   var appVersion: String { "appVersion".localized() }
   var OSVersion: String { "OSVersion".localized() }
   var deviceModel: String { "deviceModel".localized() }
   var domain: String { "domain".localized() }
   var licenseIssuedBefore: String { "licenseIssuedBefore".localized() }
   var undefined: String { "undefined".localized() }

   //FeedbackScene
   var feedback: String { "feedback".localized() }
   var feedbackMainText: String { "feedbackMainText".localized() }
   var emailForFeedback: String { "emailForFeedback".localized() }
   var tgForFeedback: String { "tgForFeedback".localized() }
   var language: String { "language".localized() }
   
   // MainScene
   var events: String { "events".localized() }
   var balance: String { "balance".localized() }
   var challenges: String { "challenges".localized() }
   var benefitCafe: String { "benefitCafe".localized() }
   var history: String { "history".localized() }
   var analytics: String { "analytics".localized() }
   var settings: String { "settings".localized() }
   var main: String { "main".localized() }
   var newTransactForYou: String { "newTransactForYou".localized() }
   var newChallenge: String { "newChallenge".localized() }
   var recommend: String { "recommend".localized() }

   // FeedViewModels
   var all1: String { "all1".localized() }
   var purchases: String { "purchases".localized() }
   var transactions: String { "transactions".localized() }
   var gratitudes: String { "gratitudes".localized() }
   var publicGratitude: String { "publicGratitude".localized() }
   var news: String { "news".localized() }

   // FeedPresenters
   var youReceived: String { "youReceived".localized() }
   var fromLowercase: String { "fromLowercase".localized() }
   var someoneReceived: String { "someoneReceived".localized() }
   var wonTheChallenge: String { "wonTheChallenge".localized() }
   var challengeCreated: String { "challengeCreated".localized() }
   var byUser: String { "byUser".localized() }

   // HistoryPresenters
   var forLowercase: String { "forLowercase".localized() }
   var refillFromSystem: String { "refillFromSystem".localized() }
   var forChallengeFee: String { "forChallengeFee".localized() }
   var challengeReward: String { "challengeReward".localized() }
   var refundFromChallenge: String { "refundFromChallenge".localized() }
   var purchase: String { "purchase".localized() }
   var purchaseUppercase: String { "purchaseUppercase".localized() }
   var refundFromMarket: String { "refundFromMarket".localized() }
   var systemRefill: String { "systemRefill".localized() }
   var creatingChallenge: String { "creatingChallenge".localized() }
   var winningTheChallenge: String { "winningTheChallenge".localized() }
   var refundPrizeFund: String { "refundPrizeFund".localized() }
   var refundBenefit: String { "refundBenefit".localized() }
   var systemDebit: String { "systemDebit".localized() }
   

   // ChallengeCellPresenters
   var fromSpaceAfter: String { "fromSpaceAfter".localized() }
   var winnersCount: String { "winnersCount".localized() }
   var prizeFund: String { "prizeFund".localized() }
   var awardeesCount: String { "awardeesCount".localized() }
   var active: String { "active".localized() }
   var completed: String { "completed".localized() }
   var deferred: String { "deferred".localized() }
   var updated: String { "updated".localized() }
   var headStartBalance: String { "headStartBalance".localized() }
   var usersStartBalance: String { "usersStartBalance".localized() }

   // NotificationsScene
   var notifications: String { "notifications".localized() }
   var surveyFinished: String { "surveyFinished".localized() }
   var surveyClosesTomorrow: String { "surveyClosesTomorrow".localized() }
   var newSurvey: String { "newSurvey".localized() }
   
   //NotificationsTitles
   var notificationTitleGratitude: String { "notificationTitleGratitude".localized() }
   var notificationTitleComment : String { "notificationTitleComment".localized() }
   var notificationTitleReaction : String { "notificationTitleReaction".localized() }
   var notificationTitleNewVictory : String { "notificationTitleNewVictory".localized() }
   var notificationTitleNewApplication : String { "notificationTitleNewApplication".localized() }
   var notificationTitleNewOrder : String { "notificationTitleNewOrder".localized() }
   var notificationTitleChallengeExpiration : String { "notificationTitleChallengeExpiration".localized() }
   var notificationTitleSurveyExpiration : String { "notificationTitleSurveyExpiration".localized() }
   var notificationTitleChallenge : String { "notificationTitleChallenge".localized() }
   var notificationTitleNewSurvey : String { "notificationTitleNewSurvey".localized() }
   
   //NotificationTexts
   var youWonChallenge: String { "youWonChallenge".localized() } //"Вы победили в челлендже "
   var newChallengePrefix: String { "newChallengePrefix".localized() } // "Новый челлендж "
   var challengePrefix: String { "challengePrefix".localized() } // "Челлендж "
   var finishesTommorow: String { "finishesTommorow".localized() } // " завершается завтра"
   var newOrderFor: String { "newOrderFor".localized() } // "Новый заказ на "
   var allParticipantsFinishedSurvey: String  { "allParticipantsFinishedSurvey".localized() } //"Все участники прошли опрос "
   var tommorowAt: String { "tommorowAt".localized() } // "Завтра в "
   var closesAccessToSurvey: String { "closesAccessToSurvey".localized() }// " закрывается доступ к прохождению опроса "
   var finishesSurvey: String { "finishesSurvey".localized() }// " завершается опрос "
   var hurryUpToParticipate: String { "hurryUpToParticipate".localized() } //". Успей поучаствовать!"
   var createdNewSurvey: String { "createdNewSurvey".localized() } //"Создан новый опрос "
   var newComment: String { "newComment".localized() } // "Новый комментарий "
   var newReaction: String { "newReaction".localized() } //"Новая реакция "
   var newReport: String { "newReport".localized() } //"Новый отчет "
   var forTransaction: String { "forTransaction".localized() }//"к переводу "
   var forChallenge: String { "forChallenge".localized() } // "к челленджу "
   
   // ChallengeDetailsScene
   var challenge: String { "challenge".localized() }

   // ChallengeDetailsViewModel
   var dateOfCompletion: String { "dateOfCompletion".localized() }
   var dateOfStart: String { "dateOfStart".localized() }
   var organizer: String { "organizer".localized() }

   // ChallResultsPresenters
   var yourPrize: String { "yourPrize".localized() }

   // CHallengeResultScene
   var result: String { "result".localized() }

   // ChallengeResCancelScene
   var rejectApplication: String { "rejectApplication".localized() }

   // ChallengeSettingsScene
   var setLimitsIfNeeded: String { "setLimitsIfNeeded".localized() }
   var showApplicantsSection: String { "showApplicantsSection".localized() }
   var multipleReportsSection: String { "multipleReportsSection".localized() }

   // ChallengeCreateScene
   var basicInfo: String { "basicInfo".localized() }
   var fillChallengeInfo: String { "fillChallengeInfo".localized() }
   var nameOfObject: String { "nameOfObject".localized() }
   var challDateOfStart: String { "challDateOfStart".localized() }
   var challDateOfCompletion: String { "challDateOfCompletion".localized() }
   var setPrizeFund: String { "setPrizeFund".localized() }
   var setAwardeesCount: String { "setAwardeesCount".localized() }
   var challengeCover: String { "challengeCover".localized() }
   var additionalSettings: String { "additionalSettings".localized() }
   var personalAccount: String { "personalAccount".localized() }
   var organizationAccount: String { "organizationAccount".localized() }
   var votingChallenge: String { "votingChallenge".localized() }
   var defaultChallenge: String { "defaultChallenge".localized() }
   
   //ChallengeEditScene
   var editChallengeTitle: String { "editChallengeTitle".localized() }
   var deleteChallenge: String { "deleteChallenge".localized() }

   // ChallengeTemplateCreateScene
   var fillChallengeTemplateInfo: String { "fillChallengeTemplateInfo".localized() }

   // TransactDetailsScene
   var gratitude: String { "gratitude".localized() }

   // FeedDetailsBlock
   var text: String { "text".localized() }
   var forWhat: String { "forWhat".localized() }
   var photography: String { "photography".localized() }
   var photographies: String { "photographies".localized() }
   var attachments: String { "attachments".localized() }
   var sticker: String { "sticker".localized() }
   var reportText: String { "reportText".localized() }
   var liked: String { "liked".localized() }

   // SettingsScene
   var privacyPolicy: String { "privacyPolicy".localized() }
   var termsOfUse: String { "termsOfUse".localized() }

   // ChangeOrganizationVM
   var currentOrganization: String { "currentOrganization".localized() }
   var chooseOrganization: String { "chooseOrganization".localized() }
   var organizations: String { "organizations".localized() }

   // VerifyViewModels
   var agreementText: String { "agreementText".localized() }
   var agreementPolicy: String { "agreementPolicy".localized() }
   var agreementTermsOfUse: String { "agreementTermsOfUse".localized() }
   var agreeWith: String { "agreeWith".localized() }
   var andConditions: String { "andConditions".localized() }

   // TransactOptionsVm
   var anonymously: String { "anonymously".localized() }
   var showForEveryone: String { "showForEveryone".localized() }

   // StickerGalleryVm
   var chooseSticker: String { "chooseSticker".localized() }

   // TransactUserBlock
   var youSent: String { "youSent".localized() }
   var sentForChallenge: String { "sentForChallenge".localized() }
   var youReceivedFrom: String { "youReceivedFrom".localized() }
   var youWantedToSend: String { "youWantedToSend".localized() }

   // TransactInfoBlockVM
   var message: String { "message".localized() }
   var gratitudeStatus: String { "gratitudeStatus".localized() }
   var information: String { "information".localized() }
   var gratitudeType: String { "gratitudeType".localized() }
   var incomingGratitude: String { "incomingGratitude".localized() }
   var rejectionReason: String { "rejectionReason".localized() }

   // MyProfileScene
   var myProfile: String { "myProfile".localized() }
   var hello: String { "hello".localized() }

   // UserProfileScene
   var profile: String { "profile".localized() }

   // UserLocationBlock
   var location: String { "location".localized() }
   var address: String { "address".localized() }

   // EditContactsScene
   var contactDetails: String { "contactDetails".localized() }

   // EditContactVM
   var surnameField: String { "surnameField".localized() }
   var nameField: String { "nameField".localized() }
   var middleField: String { "middleField".localized() }
   var gender: String { "gender".localized() }
   var emailField: String { "emailField".localized() }
   var phoneField: String { "phoneField".localized() }
   var birthdateField: String { "birthdateField".localized() }
   var birthday: String { "birthday".localized() }
   var hideYearOfBirth: String { "hideYearOfBirth".localized() }

   // Gender
   var man: String { "man".localized() }
   var woman: String { "woman".localized() }
   var notIndicated: String { "notIndicated".localized() }

   // UserStatus
   var inOfficeStatus: String { "inOfficeStatus".localized() }
   var vactionStatus: String { "vactionStatus".localized() }
   var remoteStatus: String { "remoteStatus".localized() }
   var sickLeaveStatus: String { "sickLeaveStatus".localized() }

   // BaseFilterPopupScene
   var apply: String { "apply".localized() }
   var reset: String { "reset".localized() }
   var filter: String { "filter".localized() }

   // WorkingPlaceBlock
   var workingPlace: String { "workingPlace".localized() }
   var company: String { "company".localized() }
   var department: String { "department".localized() }
   var jobTitle: String { "jobTitle".localized() }

   // UserRoleBlack
   var role: String { "role".localized() }

   // UserLastRateBlock
   var engagementIndexForCurrentPeriod: String { "engagementIndexForCurrentPeriod".localized() }
   var engagementIndex: String { "engagementIndex".localized() }

   // HereIsEmpty
   var hereIsEmpty: String { "hereIsEmpty".localized() }
   var firstComment: String { "firstComment".localized() }

   var changeOrganizationPopupTitle: String { "changeOrganizationPopupTitle".localized() }

   var noUserDataWarning: String { "noUserDataWarning".localized() }
   var goToSettings: String { "goToSettings".localized() }

   var challengeType: String { "challengeType".localized() }
   var challengeСover: String { "challengeСover".localized() }

   var deleteCategory: String { "deleteCategory".localized() }
   var deleteCategoryError: String { "deleteCategoryError".localized() }

   // oauth
   var loginViaVK: String { "loginViaVK".localized() }
   var connectVK: String { "connectVK".localized() }
   var connectVKSucceed: String { "connectVKSucceed".localized() }

   // extra
   var or: String { "or".localized() }
   var toTheEndPeriodSuffix: String { "toTheEndPeriodSuffix".localized() }

   // new challenges

   var challengeChains: String { "challengeChains".localized() }
   var completedChains: String { "completedChains".localized() }
   var challengeIsUnavailable: String { "challengeIsUnavailable".localized() }
   var tasksTotal: String { "tasksTotal".localized() }
   var reward: String { "reward".localized() }
   var finishDate: String { "finishDate".localized() }

   // Languages
   var englishLanguage: String { "englishLanguage".localized() }
   var russianLanguage: String { "russianLanguage".localized() }
   
   // alert
   var changeLanguageAlert: String { "changeLanguageAlert".localized() }

   // awards
   var awards: String { "awards".localized() }
   var myAwards: String { "myAwards".localized() }
   var uniqueAwards: String { "uniqueAwards".localized() }
   var getAward: String { "getAward".localized() }
   var awardReceived: String { "awardReceived".localized() }
   var awardReceivedDate: String { "awardReceivedDate".localized() }
   var setAwardToStatusButtonTItle: String { "setAwardToStatusButtonTItle".localized() }
   var steps: String { "steps".localized() }
   var chainSteps: String { "chainSteps".localized() }
   var challengeChain: String { "challengeChain".localized() }
   var results: String { "results".localized() }

   var mode: String { "mode".localized() }
   var toChallenge: String { "toChallenge".localized() }
   var report: String { "report".localized() }
   
   var taskStatus: String { "taskStatus".localized() }
   var done: String { "done".localized() }
   
   var youHave: String { "youHave".localized() }
   var newNotifications: String { "newNotifications".localized() }
   var newNotification: String { "newNotification".localized() }
   
   var workFormat: String { "workFormat".localized() }
   var workingStatus: String { "workingStatus".localized() }
}

extension TextsProtocol {
   func pluralCurrencyForForm(_ form: PluralForms.CaseForms) -> String {
      BrandSettings.shared.pluralCurrency(.forForm(form))
   }

   func pluralCurrencyWithValue(_ value: Int, case: Cases) -> String {
      "\(value) " + BrandSettings.shared.pluralCurrency(.forSum(value, case: `case`))
   }

   func pluralCurrencyForValue(_ value: Int, case: Cases) -> String {
      BrandSettings.shared.pluralCurrency(.forSum(value, case: `case`))
   }

   func pluralCurrencyWithValue(_ value: String, case: Cases) -> String {
      let intValue = Int(value) ?? 0
      return "\(value) " + BrandSettings.shared.pluralCurrency(.forSum(intValue, case: `case`))
   }

   func pluralCurrencyForValue(_ value: String, case: Cases) -> String {
      let intValue = Int(value) ?? 0
      return BrandSettings.shared.pluralCurrency(.forSum(intValue, case: `case`))
   }
}

struct Texts: TextsProtocol {}

extension String {
   func localized(_ lang: String? = nil) -> String {
      var value: String?
      if lang == nil {
         value = UserDefaults.standard.loadValue(forKey: .appLanguage)
      }
      if value == nil {
         value = "ru"
      }

      let path = Bundle.main.path(forResource: value, ofType: "lproj")
      let bundle = Bundle(path: path!)

      return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
   }
}
