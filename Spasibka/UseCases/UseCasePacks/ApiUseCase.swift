//
//  CommonUseCasePack.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation
import StackNinja

protocol Retainable {
   var retainer: Retainer { get }
}

// Не забываем Ретайнить ворки
// Нельзя из юзкейза использовать другой юзкейз набора с авторитейном  (ретайнеры переполняются у другого юзкезв)

final class ApiUseCase<Asset: AssetProtocol>: InitProtocol, Assetable, WorkBasket, Retainable {
   //

   init() {}

   let retainer = Retainer()

   var safeStringStorage: StringStorageWorker {
      StringStorageWorker(engine: Asset.service.safeStringStorage)
   }

   // MARK: - UseCases

   // Login / Logout
   var login: LoginUseCase.WRK {
      LoginUseCase(apiEngine: Asset.service.apiWorks)
         .retainedWork(retainer)
   }

   var verifyCode: VerifyCodeUseCase.WRK {
      VerifyCodeUseCase(
         verifyCodeApiWorker: verifyCodeApiWorker
      )
      .retainedWork(retainer)
   }

   var logout: LogoutUseCase.WRK {
      LogoutUseCase(
         loadToken: loadToken,
         logoutApiModel: logoutApiModel
      )
      .retainedWork(retainer)
   }
   
   var getFlag: GetFlagUseCase.WRK {
      GetFlagUseCase(
         apiEngine: Asset.service.apiWorks
      )
      .retainedWork(retainer)
   }
   
   var setFlag: SetFlagUseCase.WRK {
      SetFlagUseCase(
         apiEngine: Asset.service.apiWorks
      )
      .retainedWork(retainer)
   }

   // Profile

   var loadMyProfile: LoadProfileUseCase.WRK {
      LoadProfileUseCase(
         loadToken: loadToken,
         saveUserNameWork: saveCurrentUserName,
         saveUserIdWork: saveCurrentUserId,
         saveProfileIdWork: saveCurrentProfileId,
         userProfileApiModel: myProfileApiModel,
         saveUserRole: saveCurrentUserRole
      )
      .retainedWork(retainer)
   }

   var loadBalance: LoadBalanceUseCase.WRK {
      LoadBalanceUseCase(
         loadToken: loadToken,
         balanceApiModel: balanceApiModel
      )
      .retainedWork(retainer)
   }

   var userSearch: UserSearchUseCase.WRK {
      UserSearchUseCase(searchUserApiModel: searchUserApiWorker)
         .retainedWork(retainer)
   }

   var getTransactions: GetTransactionsUseCase.WRK {
      GetTransactionsUseCase(
         safeStringStorage: safeStringStorage,
         getTransactionsApiWorker: getTransactionsApiWorker
      )
      .retainedWork(retainer)
   }

   var sendCoin: SendCoinUseCase.WRK {
      SendCoinUseCase(
         sendCoinApiModel: sendCoinApiWorker
      )
      .retainedWork(retainer)
   }

   var getTransactionById: GetTransactionByIdUseCase.WRK {
      GetTransactionByIdUseCase(
         safeStringStorage: safeStringStorage,
         getTransactionByIdApiModel: getTransactionByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getTransactionsByPeriod: GetTransactionsByPeriodUseCase.WRK {
      GetTransactionsByPeriodUseCase(
         safeStringStorage: safeStringStorage,
         getTransactionsByPeriodApiModel: getTransactionsByPeriodApiWorker
      )
      .retainedWork(retainer)
   }

   var cancelTransactionById: CancelTransactionByIdUseCase.WRK {
      CancelTransactionByIdUseCase(
         safeStringStorage: safeStringStorage,
         cancelTransactionByIdApiWorker: cancelTransactionByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getUsersList: GetUsersListUseCase.WRK {
      GetUsersListUseCase(
         safeStringStorage: safeStringStorage,
         getUsersListApiWorker: getUsersListApiWorker
      )
      .retainedWork(retainer)
   }

   var getPeriods: GetPeriodsUseCase.WRK {
      GetPeriodsUseCase(
         safeStringStorage: safeStringStorage,
         getPeriodsApiWorker: getPeriodsApiWorker
      )
      .retainedWork(retainer)
   }

   var getStatByPeriodId: GetStatByPeriodIdUseCase.WRK {
      GetStatByPeriodIdUseCase(
         safeStringStorage: safeStringStorage,
         getStatByPeriodIdApiWorker: getStatByPeriodIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getCurrentPeriod: GetCurrentPeriodUseCase.WRK {
      GetCurrentPeriodUseCase(
         safeStringStorage: safeStringStorage,
         getCurrentPeriodApiWorker: getCurrentPeriodApiWorker
      )
      .retainedWork(retainer)
   }

   var getPeriodByDate: GetPeriodByDateUseCase.WRK {
      GetPeriodByDateUseCase(
         safeStringStorage: safeStringStorage,
         getPeriodByDateApiWorker: getPeriodByDateApiWorker
      )
      .retainedWork(retainer)
   }

   var getPeriodsFromDate: GetPeriodsFromDateUseCase.WRK {
      GetPeriodsFromDateUseCase(
         safeStringStorage: safeStringStorage,
         getPeriodsFromDateApiWorker: getPeriodsFromDateApiWorker
      )
      .retainedWork(retainer)
   }

   var updateProfileImage: UpdateProfileImageUseCase.WRK {
      UpdateProfileImageUseCase(
         safeStringStorage: safeStringStorage,
         updateProfileImageApiWorker: updateProfileImageApiWorker
      )
      .retainedWork(retainer)
   }

   var updateContact: UpdateContactUseCase.WRK {
      UpdateContactUseCase(
         safeStringStorage: safeStringStorage,
         updateContactApiWorker: updateContactApiWorker
      )
      .retainedWork(retainer)
   }

   var createContact: CreateContactUseCase.WRK {
      CreateContactUseCase(
         safeStringStorage: safeStringStorage,
         createContactApiWorker: createContactApiWorker
      )
      .retainedWork(retainer)
   }

   var updateProfile: UpdateProfileUseCase.WRK {
      UpdateProfileUseCase(
         safeStringStorage: safeStringStorage,
         updateProfileApiWorker: updateProfileApiWorker
      )
      .retainedWork(retainer)
   }

   var createFewContacts: CreateFewContactsUseCase.WRK {
      CreateFewContactsUseCase(
         safeStringStorage: safeStringStorage,
         createFewContactsApiWorker: createFewContactsApiWorker
      )
      .retainedWork(retainer)
   }

   var getTags: GetTagsUseCase.WRK {
      GetTagsUseCase(
         getTagsApiWorker: getTagsApiWorker
      )
      .retainedWork(retainer)
   }

   var getTagById: GetTagByIdUseCase.WRK {
      GetTagByIdUseCase(
         getTagByIdApiWorker: getTagByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getProfileById: GetProfileByIdUseCase.WRK {
      GetProfileByIdUseCase(
         safeStringStorage: safeStringStorage,
         getProfileByIdApiWorker: getProfileByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var pressLike: PressLikeUseCase.WRK {
      PressLikeUseCase(
         safeStringStorage: safeStringStorage,
         pressLikeApiWorker: pressLikeApiWorker
      )
      .retainedWork(retainer)
   }

   var getLikesCommentsStat: GetLikesCommentsStatUseCase.WRK {
      GetLikesCommentsStatUseCase(
         safeStringStorage: safeStringStorage,
         getLikesCommentsStatApiWorker: getLikesCommentsStatApiWorker
      )
      .retainedWork(retainer)
   }

   var getComments: GetCommentsUseCase.WRK {
      GetCommentsUseCase(
         safeStringStorage: safeStringStorage,
         getCommentsApiWorker: getCommentsApiWorker
      )
      .retainedWork(retainer)
   }

   var createComment: CreateCommentUseCase.WRK {
      CreateCommentUseCase(
         safeStringStorage: safeStringStorage,
         createCommentApiWorker: createCommentApiWorker
      )
      .retainedWork(retainer)
   }

   var updateComment: UpdateCommentUseCase.WRK {
      UpdateCommentUseCase(
         safeStringStorage: safeStringStorage,
         updateCommentApiWorker: updateCommentApiWorker
      )
      .retainedWork(retainer)
   }

   var deleteComment: DeleteCommentUseCase.WRK {
      DeleteCommentUseCase(
         safeStringStorage: safeStringStorage,
         deleteCommentApiWorker: deleteCommentApiWorker
      )
      .retainedWork(retainer)
   }

   var getLikesByTransaction: GetLikesByTransactionUseCase.WRK {
      GetLikesByTransactionUseCase(
         safeStringStorage: safeStringStorage,
         getLikesByTransactionApiWorker: getLikesByTransactionApiWorker
      )
      .retainedWork(retainer)
   }


   var getChallengeById: GetChallengeByIdUseCase.WRK {
      GetChallengeByIdUseCase(
         safeStringStorage: safeStringStorage,
         getChallengeByIdApiWorker: getChallengeByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getChallengeContenders: GetChallengeContendersUseCase.WRK {
      GetChallengeContendersUseCase(
         safeStringStorage: safeStringStorage,
         getChallengeContendersApiWorker: getChallengeContendersApiWorker
      )
      .retainedWork(retainer)
   }

   var createChallenge: CreateChallengeUseCase.WRK {
      CreateChallengeUseCase(
         safeStringStorage: safeStringStorage,
         createChallengeApiWorker: createChallengeApiWorker
      )
      .retainedWork(retainer)
   }

   var getChallengeWinners: GetChallengeWinnersUseCase.WRK {
      GetChallengeWinnersUseCase(
         safeStringStorage: safeStringStorage,
         getChallengeWinnersApiWorker: getChallengeWinnersApiWorker
      )
      .retainedWork(retainer)
   }

   var createChallengeReport: CreateChallengeReportUseCase.WRK {
      CreateChallengeReportUseCase(
         safeStringStorage: safeStringStorage,
         createChallengeReportApiWorker: createChallengeReportApiWorker
      )
      .retainedWork(retainer)
   }

   var checkChallengeReport: CheckChallengeReportUseCase.WRK {
      CheckChallengeReportUseCase(
         safeStringStorage: safeStringStorage,
         checkChallengeReportApiWorker: checkChallengeReportApiWorker
      )
      .retainedWork(retainer)
   }

   var getSendCoinSettings: GetSendCoinSettingsUseCase.WRK {
      GetSendCoinSettingsUseCase(
         getSendCoinSettingsApiWorker: getSendCoinSettingsApiWorker
      )
      .retainedWork(retainer)
   }

   var getChallengeResult: GetChallengeResultUseCase.WRK {
      GetChallengeResultUseCase(
         safeStringStorage: safeStringStorage,
         getChallengeResultApiWorker: getChallengeResultApiWorker
      )
      .retainedWork(retainer)
   }

   var getChallengeWinnersReports: GetChallWinnersReportsUseCase.WRK {
      GetChallWinnersReportsUseCase(
         safeStringStorage: safeStringStorage,
         getChallWinnersReportsApiWorker: getChallWinnersReportsApiWorker
      )
      .retainedWork(retainer)
   }

   var getChallengeReport: GetChallengeReportUseCase.WRK {
      GetChallengeReportUseCase(
         safeStringStorage: safeStringStorage,
         getChallengeReportApiWorker: getChallengeReportApiWorker
      )
      .retainedWork(retainer)
   }

   var getEvents: GetEventsUseCase.WRK {
      GetEventsUseCase(
         safeStringStorage: safeStringStorage,
         getEventsApiWorker: getEventsApiWorker
      )
      .retainedWork(retainer)
   }

   var getEventsTransact: GetEventsTransactUseCase.WRK {
      GetEventsTransactUseCase(
         safeStringStorage: safeStringStorage,
         getEventsTransactApiWorker: getEventsTransactApiWorker
      )
      .retainedWork(retainer)
   }

   var getEventsWinners: GetEventsWinnersUseCase.WRK {
      GetEventsWinnersUseCase(
         safeStringStorage: safeStringStorage,
         getEventsWinnersApiWorker: getEventsWinnersApiWorker
      )
      .retainedWork(retainer)
   }

   var getEventsChall: GetEventsChallUseCase.WRK {
      GetEventsChallUseCase(
         safeStringStorage: safeStringStorage,
         getEventsChallApiWorker: getEventsChallApiWorker
      )
      .retainedWork(retainer)
   }

   var getEventsTransactById: GetEventsTransactByIdUseCase.WRK {
      GetEventsTransactByIdUseCase(
         safeStringStorage: safeStringStorage,
         getEventsTransactByIdApiModel: getEventsTransactByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var setFcmToken: SetFcmTokenUseCase.WRK {
      SetFcmTokenUseCase(
         safeStringStorage: safeStringStorage,
         setFcmTokenApiWorker: setFcmTokenApiWorker
      )
      .retainedWork(retainer)
   }

   var removeFcmToken: RemoveFcmTokenUseCase.WRK {
      RemoveFcmTokenUseCase(
         safeStringStorage: safeStringStorage,
         removeFcmTokenApiWorker: removeFcmTokenApiWorker
      )
      .retainedWork(retainer)
   }

   var getNotifications: GetNotificationsUseCase.WRK {
      GetNotificationsUseCase(
         safeStringStorage: safeStringStorage,
         getNotificationsApiWorker: getNotificationsApiWorker
      )
      .retainedWork(retainer)
   }

   var notificationReadWithId: NotificationReadWithIdUseCase.WRK {
      NotificationReadWithIdUseCase(
         safeStringStorage: safeStringStorage,
         notificationReadWithIdApiWorker: notificationReadWithIdApiWorker
      ).retainedWork(retainer)
   }

   var getNotificationsAmount: GetNotificationsAmountUseCase.WRK {
      GetNotificationsAmountUseCase(
         safeStringStorage: safeStringStorage,
         getNotificationsAmountApiWorker: getNotificationsAmountApiWorker
      ).retainedWork(retainer)
   }

   var getUserOrganizations: GetUserOrganizationsUseCase.WRK {
      GetUserOrganizationsUseCase(
         safeStringStorage: safeStringStorage,
         getUserOrganizationsApiWorker: getUserOrganizationsApiWorker
      ).retainedWork(retainer)
   }

   var changeOrganization: ChangeOrganizationUseCase.WRK {
      ChangeOrganizationUseCase(
         safeStringStorage: safeStringStorage,
         changeOrganizationApiWorker: changeOrganizationApiWorker,
         getAuthMethodApiWork: getAutMethod
      ).retainedWork(retainer)
   }

   var changeOrgVerifyCode: ChangeOrgVerifyCodeUseCase.WRK {
      ChangeOrgVerifyCodeUseCase(
         changeOrgVerifyApiWorker: changeOrgVerifyApiWorker
      )
      .retainedWork(retainer)
   }

   var chooseOrganization: ChooseOrgUseCase.WRK {
      ChooseOrgUseCase(
         chooseOrgApiWorker: chooseOrgApiWorker
      )
      .retainedWork(retainer)
   }

   var getLikes: GetLikesUseCase.WRK {
      GetLikesUseCase(
         safeStringStorage: safeStringStorage,
         getLikesApiWorker: getLikesApiWorker
      )
      .retainedWork(retainer)
   }

   var createChallengeGet: CreateChallengeGetUseCase.WRK {
      CreateChallengeGetUseCase(
         safeStringStorage: safeStringStorage,
         createChallengeGetApiWorker: createChallengeGetApiWorker
      )
      .retainedWork(retainer)
   }

   var closeChallenge: CloseChallengeUseCase.WRK {
      CloseChallengeUseCase(
         safeStringStorage: safeStringStorage,
         closeChallengeApiWorker: closeChallengeApiWorker
      )
      .retainedWork(retainer)
   }

   var getUserStats: GetUserStatsUseCase.WRK {
      GetUserStatsUseCase(
         safeStringStorage: safeStringStorage,
         getUserStatsWorker: getUserStatsApiWorker
      )
      .retainedWork(retainer)
   }

   var getOrganizationSettings: GetOrgSettingsUseCase.WRK {
      GetOrgSettingsUseCase(
         safeStringStorage: safeStringStorage,
         getOrgSettingsApiWorker: getOrgSettingsApiWorker
      )
      .retainedWork(retainer)
   }

   var getOrganizationBrandSettings: GetOrgBrandSettingsUseCase.WRK {
      GetOrgBrandSettingsUseCase(
         apiEngine: Asset.service.apiWorks,
         stringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getMarketItems: GetMarketItemsUseCase.WRK {
      GetMarketItemsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getMarketItemById: GetMarketItemByIdUseCase.WRK {
      GetMarketItemByIdUseCase(
         safeStringStorage: safeStringStorage,
         getMarketItemByIdApiWorker: getMarketItemByIdApiWorker
      )
      .retainedWork(retainer)
   }

   var getMarketCategories: GetMarketCategoriesUseCase.WRK {
      GetMarketCategoriesUseCase(
         safeStringStorage: safeStringStorage,
         getMarketCategoriesApiWorker: getMarketCategoriesApiWorker
      )
      .retainedWork(retainer)
   }

   var addToCart: AddToCartUseCase.WRK {
      AddToCartUseCase(
         safeStringStorage: safeStringStorage,
         addToCartApiWorker: addToCartApiWorker
      )
      .retainedWork(retainer)
   }

   var getCartItems: GetCartItemsUseCase.WRK {
      GetCartItemsUseCase(
         safeStringStorage: safeStringStorage,
         getCartItemsApiWorker: getCartItemsApiWorker
      )
      .retainedWork(retainer)
   }

   var deleteCartItem: DeleteCartItemUseCase.WRK {
      DeleteCartItemUseCase(
         safeStringStorage: safeStringStorage,
         deleteCartItemApiWorker: deleteCartItemApiWorker
      )
      .retainedWork(retainer)
   }

   var getOrders: GetOrdersUseCase.WRK {
      GetOrdersUseCase(
         safeStringStorage: safeStringStorage,
         getOrdersApiWorker: getOrdersApiWorker
      )
      .retainedWork(retainer)
   }

   var postOrders: PostOrdersUseCase.WRK {
      PostOrdersUseCase(
         safeStringStorage: safeStringStorage,
         postOrdersApiWorker: postOrdersApiWorker
      )
      .retainedWork(retainer)
   }

   var getStickerpacks: GetStickerpacksUseCase.WRK {
      GetStickerpacksUseCase(
         safeStringStorage: safeStringStorage,
         getStickerpacksApiWorker: getStickerpacksApiWorker
      )
      .retainedWork(retainer)
   }

   var getStickers: GetStickersUseCase.WRK {
      GetStickersUseCase(
         safeStringStorage: safeStringStorage,
         getStickersApiWorker: getStickersApiWorker
      )
      .retainedWork(retainer)
   }

   var getFile: GetFileUseCase.WRK {
      GetFileUseCase(
         safeStringStorage: safeStringStorage,
         getFileApiWorker: getFileApiWorker
      )
      .retainedWork(retainer)
   }

   var getColleagues: GetColleaguesUseCase.WRK {
      GetColleaguesUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getAvailableMarkets: GetAvailableMarketsUseCase.WRK {
      GetAvailableMarketsUseCase(
         safeStringStorage: safeStringStorage,
         getAvailableMarketsApiWorker: getAvailableMarketsApiWorker
      )
      .retainedWork(retainer)
   }

   var getDepartmentsTree: GetDepartmentsTreeUseCase.WRK {
      GetDepartmentsTreeUseCase(
         safeStringStorage: safeStringStorage,
         apiEngine: Asset.service.apiEngine
      )
      .retainedWork(retainer)
   }

   var getChallengeTemplate: GetChallTemplateByIdUseCase.WRK {
      GetChallTemplateByIdUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var createChallengeTemplate: CreateChallengeTemplateUseCase.WRK {
      CreateChallengeTemplateUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var updateChallengeTemplate: UpdateChallengeTemplateUseCase.WRK {
      UpdateChallengeTemplateUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getChallengeTemplates: GetChallengeTemplatesUseCase.WRK {
      GetChallengeTemplatesUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var createCommunity: CreateCommunityUseCase.WRK {
      CreateCommunityUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var createCommunityWithParams: CreateCommunityWithParamsUseCase.WRK {
      CreateCommunityWithParamsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var createPeriod: CreatePeriodUseCase.WRK {
      CreatePeriodUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getInviteLink: GetInviteLinkUseCase.WRK {
      GetInviteLinkUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var communityInvite: CommunityInviteUseCase.WRK {
      CommunityInviteUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   // MARK: - Location by IP

   var getLocationByIP: LocationByIpUseCase.WRK {
      LocationByIpUseCase(
         locationByApiWorker: .init(apiEngine: Asset.service.apiEngine)
      )
      .retainedWork(retainer)
   }

   // MARK: - Profile

   var getLastPeriodRate: GetLastPeriodRateUseCase.WRK {
      GetLastPeriodRateUseCase(
         apiEngine: Asset.service.apiEngine,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   // MARK: - Categories

   var getCategories: GetCategoriesUseCase.WRK {
      GetCategoriesUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var createCategory: CreateCategoryUseCase.WRK {
      CreateCategoryUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var deleteCategory: DeleteCategoryUseCase.WRK {
      DeleteCategoryUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var deleteChallenge: DeleteChallengeUseCase.WRK {
      DeleteChallengeUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var updateChallenge: UpdateChallengeUseCase.WRK {
      UpdateChallengeUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var deleteChallengeTemplate: DeleteChallengeTemplateUseCase.WRK {
      DeleteChallengeTemplateUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var changeOrganizationViaVK: ChangeOrganizationViaVKUseCase.WRK {
      ChangeOrganizationViaVKUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   // MARK: - VK Auth

   var vkAuth: VKAuthApiWork.WRK {
      VKAuthApiWork(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var vkGetAccessToken: VKGetAccessToken.WRK {
      VKGetAccessToken(apiWorks: Asset.service.apiWorks)
         .retainedWork(retainer)
   }

   var vkChooseOrg: VKChooseOrgUseCase.WRK {
      VKChooseOrgUseCase(apiWorks: Asset.service.apiWorks)
         .retainedWork(retainer)
   }
   
   var getAutMethod: GetAuthMethodUseCase.WRK {
      GetAuthMethodUseCase(apiWorks: Asset.service.apiWorks, safeStringStorage: safeStringStorage)
         .retainedWork(retainer)
   }

   // MARK: - Dependencies

   private var myProfileApiModel: GetMyProfileApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var verifyCodeApiWorker: VerifyApiModel { .init(apiEngine: Asset.service.apiEngine) }
   private var logoutApiModel: LogoutApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var balanceApiModel: GetBalanceApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var searchUserApiWorker: SearchUserApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var sendCoinApiWorker: SendCoinApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getTransactionsApiWorker: GetTransactionsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getTransactionByIdApiWorker: GetTransactionByIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getUsersListApiWorker: GetUsersListApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getPeriodsApiWorker: GetPeriodsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getStatByPeriodIdApiWorker: GetStatByPeriodIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getTransactionsByPeriodApiWorker: GetTransactionsByPeriodApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var cancelTransactionByIdApiWorker: CancelTransactionByIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getCurrentPeriodApiWorker: GetCurrentPeriodApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getPeriodByDateApiWorker: GetPeriodByDateApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getPeriodsFromDateApiWorker: GetPeriodsFromDateApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var updateProfileImageApiWorker: UpdateProfileImageApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var updateContactApiWorker: UpdateContactApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var createContactApiWorker: CreateContactApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var updateProfileApiWorker: UpdateProfileApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var createFewContactsApiWorker: CreateFewContactsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getTagsApiWorker: GetTagsApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getTagByIdApiWorker: GetTagByIdApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getProfileByIdApiWorker: GetProfileByIdApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var pressLikeApiWorker: PressLikeApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getLikesCommentsStatApiWorker: GetLikesCommentsStatApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getCommentsApiWorker: GetCommentsApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var createCommentApiWorker: CreateCommentApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var updateCommentApiWorker: UpdateCommentApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var deleteCommentApiWorker: DeleteCommentApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getLikesByTransactionApiWorker: GetLikesByTransactionApiWorker { .init(apiEngine: Asset.service.apiEngine) }
//   private var getChallengesApiWorker: GetChallengesApiWorker { .init(apiEngine:
//      Asset.service.apiEngine) }
   private var getChallengeByIdApiWorker: GetChallengeByIdApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getChallengeContendersApiWorker: GetChallengeContendersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var createChallengeApiWorker: CreateChallengeApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var getChallengeWinnersApiWorker: GetChallengeWinnersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var createChallengeReportApiWorker: CreateChallengeReportApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var checkChallengeReportApiWorker: CheckChallengeReportApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getSendCoinSettingsApiWorker: GetSendCoinSettingsApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getChallengeResultApiWorker: GetChallengeResultApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getChallWinnersReportsApiWorker: GetChallWinnersReportsApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getChallengeReportApiWorker: GetChallengeReportApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getEventsApiWorker: GetEventsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getEventsTransactApiWorker: GetEventsTransactApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getEventsWinnersApiWorker: GetEventsWinnersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getEventsChallApiWorker: GetEventsChallApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getEventsTransactByIdApiWorker: GetEventsTransactByIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var setFcmTokenApiWorker: SetFcmTokenApiWorker { .init(apiEngine:
      Asset.service.apiEngine) }
   private var removeFcmTokenApiWorker: RemoveFcmTokenApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getNotificationsApiWorker: GetNotificationsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var notificationReadWithIdApiWorker: NotificationReadWithIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getNotificationsAmountApiWorker: GetNotificationsAmountApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var getUserOrganizationsApiWorker: GetUserOrganizationsApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var changeOrganizationApiWorker: ChangeOrganizationApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var changeOrgVerifyApiWorker: ChangeOrgVerifyApiWorker {
      .init(apiEngine: Asset.service.apiEngine)
   }

   private var chooseOrgApiWorker: ChooseOrgApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getLikesApiWorker: GetLikesApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var createChallengeGetApiWorker: GetCreateChallengeSettingsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var closeChallengeApiWorker: CloseChallengeApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getUserStatsApiWorker: GetUserStatsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getOrgSettingsApiWorker: GetOrgSettingsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
//   private var getMarketItemsApiWorker: GetMarketItemsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getMarketItemByIdApiWorker: GetMarketItemByIdApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getMarketCategoriesApiWorker: GetMarketCategoriesApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var addToCartApiWorker: AddToCartApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getCartItemsApiWorker: GetCartItemsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var deleteCartItemApiWorker: DeleteCartItemApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getOrdersApiWorker: GetOrdersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var postOrdersApiWorker: PostOrdersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getStickerpacksApiWorker: GetStickerpacksApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getStickersApiWorker: GetStickersApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getFileApiWorker: GetFileApiWorker { .init(apiEngine: Asset.service.apiEngine) }
   private var getAvailableMarketsApiWorker: GetAvailableMarketsApiWorker { .init(apiEngine: Asset.service.apiEngine) }
//   private var getDepartmentTreeApiWorker: GetDepartmentsTreeApiWorker { .init(apiEngine: Asset.service.apiEngine) }

   private var loadToken: LoadTokenWorker { LoadTokenWorker(safeStringStorage: safeStringStorage) }
   private var saveCurrentUserName: SaveCurrentUserUseCase {
      SaveCurrentUserUseCase(safeStringStorage: Asset.service.safeStringStorage)
   }

   private var saveCurrentUserId: SaveCurrentUserIdUseCase {
      SaveCurrentUserIdUseCase(safeStringStorage: Asset.service.safeStringStorage)
   }

   private var saveCurrentProfileId: SaveCurrentProfileIdUseCase {
      SaveCurrentProfileIdUseCase(safeStringStorage: Asset.service.safeStringStorage)
   }

   private var saveCurrentUserRole: SaveCurrentUserRoleUseCase {
      SaveCurrentUserRoleUseCase(safeStringStorage: Asset.service.safeStringStorage)
   }
}

extension ApiUseCase {
   var getAwards: GetAwardsUseCase.WRK {
      GetAwardsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var getAwardGroups: GetAwardGroupsUseCase.WRK {
      GetAwardGroupsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var gainAward: GainAwardUseCase.WRK {
      GainAwardUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var setAwardToStatus: SetAwardToStatusUseCase.WRK {
      SetAwardToStatusUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
}

extension ApiUseCase {
   var getTransactionsByGroup: GetTransactionsByGroupUseCase.WRK {
      GetTransactionsByGroupUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getChanllenges: GetChallengesUseCase.WRK {
      GetChallengesUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getChallengeGroups: GetChallengeGroupsUseCase.WRK {
      GetChallengeGroupsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getChallengeGroupById: GetChallengeGroupByIdUseCase.WRK {
      GetChallengeGroupByIdUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getChainParticipants: GetChainParticipantsUseCase.WRK {
      GetChainParticipantsUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getEventsByFilter: GetEventsByFilterUseCase.WRK {
      GetEventsByFilterUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }

   var postLike: LikeApiUseCase.WRK {
      LikeApiUseCase(
         apiWorks: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
   
   var getRecommendations: GetRecommendationsUseCase.WRK {
      GetRecommendationsUseCase(
         apiEngine: Asset.service.apiWorks,
         safeStringStorage: safeStringStorage
      )
      .retainedWork(retainer)
   }
}
