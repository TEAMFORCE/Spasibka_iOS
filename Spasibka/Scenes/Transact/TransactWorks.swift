//
//  TransactSceneWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Alamofire
import StackNinja
import UIKit

protocol TransactWorksProtocol: StorageProtocol {}

// storage
class TransacrtTempStorage: InitProtocol, ImageStorage {
   
   
   required init() {}

   var organizationID: Int = 0

   var tokens: (token: String, csrf: String) = ("", "")
   var foundUsers: [FoundUser] = []
   var recipientUser: FoundUser?
   var recipientID = 0
   var recipientUsername = ""
   var isAnonymous = false
   var isPublic = true
   var isAnonymousAvailable: Bool?

   var inputAmountText = ""
   var inputReasonText = ""

   var isCorrectCoinInput = false
   var isCorrectReasonInput = false

   var isTagsEnabled = false
   var tags: Set<Tag> = []
   var selectableTags = [SelectWrapper<Tag>]()

   var images: [UIImage] = []
   var indexes: [Int] = []

   var availableStickers: [Sticker]?
   var selectedSticker: Sticker?
}

// Transact Works - (если нужно хранилище временное, то наследуемся от BaseSceneWorks)
final class TransactWorks<Asset: AssetProtocol>: BaseWorks<TransacrtTempStorage, Asset>,
   TransactWorksProtocol
//   InputTextCachableWorks
{
   // api works
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var storageUseCase = Asset.safeStorageUseCase
   private lazy var userDefaultsWorks = Asset.userDefaultsWorks
   // parsing input
   private lazy var coinInputParser = CoinInputCheckerModel()
   private lazy var reasonInputParser = ReasonCheckerModel()

   // MARK: - Works

   var setOrganizationID: VoidWork { .init { [weak self] work in
      self?.userDefaultsWorks
         .loadValueWork()
         .doAsync(.currentOrganizationID)
         .onSuccess {
            Self.store.organizationID = $0 as Int
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}

   var loadProfileById: Work<Int, FoundUser> { .init { [weak self] work in
      self?.apiUseCase.getProfileById
         .doAsync(work.unsafeInput)
         .onSuccess {
            var userPhoto: String?
            if let photo = $0.profile.photo {
               userPhoto = photo //String(photo.dropFirst(7))
            }
            guard let userId = $0.id else { work.fail(); return }
            let foundUser = FoundUser(
               userId: userId,
               tgName: $0.profile.tgName,
               name: $0.profile.firstName,
               surname: $0.profile.surName,
               photo: userPhoto
            )
            Self.store.foundUsers = [foundUser]
            Self.store.recipientUser = foundUser
            Self.store.recipientID = foundUser.userId
            work.success(foundUser)
         }
         .onFail {
            print("failed to load profile")
            work.fail()
         }
   }.retainBy(retainer) }

   var loadBalance: Out<Balance> { apiUseCase.loadBalance }

   var loadTokens: Work<Void, Void> { .init { [weak self] work in
      self?.storageUseCase.loadBothTokens
         .doAsync()
         .onSuccess {
            Self.store.tokens.token = $0
            Self.store.tokens.csrf = $1
            work.success()
         }.onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getSettings: Work<Void, SendCoinSettings> { .init { [weak self] work in
      self?.apiUseCase.getSendCoinSettings
         .doAsync(Self.store.tokens.token)
         .onSuccess {
            Self.store.isAnonymousAvailable = $0.isAnonymousAvailable
            Self.store.isPublic = $0.isPublic
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getSelectableTags: Work<Void, [SelectWrapper<Tag>]> { .init { work in
      work.success(result: Self.store.selectableTags)
   }.retainBy(retainer) }
   
   var getIsAnonymousAvailable: Out<Bool> { .init { work in
      guard let result = Self.store.isAnonymousAvailable else { work.fail(); return }
      work.success(result)
   }.retainBy(retainer) }

   var loadTags: VoidWork { .init { [weak self] work in
      guard let self else { work.fail(); return }

      self.getSettings
         .doAsync()
         .doMap {
            $0.tags
         }
         .onSuccess {
            Self.store.selectableTags = $0.map {
               SelectWrapper(value: $0)
            }
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getTagById: Work<Int, Tag> { .init { [weak self] work in
      let request = RequestWithId(token: Self.store.tokens.token,
                                  id: work.unsafeInput)
      self?.apiUseCase.getTagById
         .doAsync(request)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }

   }.retainBy(retainer) }

   var searchUser: Work<String, [FoundUser]> { .init { [weak self] work in
      let request = SearchUserRequest(
         data: work.unsafeInput,
         token: Self.store.tokens.token,
         csrfToken: Self.store.tokens.csrf
      )

      self?.apiUseCase.userSearch
         .doAsync(request)
         .onSuccess { result in
            Self.store.foundUsers = result
            work.success(result: result)
         }.onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var enableTags: Work<Bool, Void> { .init(retainedBy: retainer) { work in
      Self.store.isTagsEnabled = work.unsafeInput
      work.success()
   } }

   var getSelectedTags: Work<Void, Set<Tag>> { .init(retainedBy: retainer) { work in
      work.success(result: Self.store.tags)
   } }

   var setTags: Work<Set<Tag>, Void> { .init(retainedBy: retainer) { work in
      Self.store.tags = work.unsafeInput
      work.success()
   }}

   var removeTag: Work<Tag, Void> { .init(retainedBy: retainer) { work in
      Self.store.tags.remove(work.unsafeInput)
      work.success()
   } }

   var sendCoins: Out<(recipient: String, info: SendCoinRequest, user: FoundUser)> { .init { [weak self] work in
      var photos: [UIImage]?
      print(Self.store.images.count)
      
      for image in Self.store.images {
         if photos == nil { photos = [] }
         let size = image.size
         let coef = size.width / size.height
         let newSize = CGSize(width: Config.imageSendSize, height: Config.imageSendSize / coef)
         let sendImage = image.resized(to: newSize)
         photos?.append(sendImage)
      }
         
      let request = SendCoinRequest(
         token: Self.store.tokens.token,
         csrfToken: Self.store.tokens.csrf,
         recipient: Self.store.recipientID,
         amount: Self.store.inputAmountText,
         reason: Self.store.inputReasonText,
         isAnonymous: Self.store.isAnonymous,
         photos: photos,
         stickerId: Self.store.selectedSticker?.id,
         isPublic: Self.store.isPublic,
         tags: Self.store.tags.map { String($0.id) }.joined(separator: " ")
      )
      guard let user = Self.store.recipientUser else { work.fail(); return }

      self?.apiUseCase.sendCoin
         .doAsync(request)
         .onSuccess {
//            self?.inputTextCacher.clearCache()
            
            let tuple = (Self.store.recipientUsername, request, user)
            work.success(result: tuple)
         }.onFail {
            work.fail()
         }
   } }

   var getUserList: Work<Void, [FoundUser]> { .init { [weak self] work in
      self?.apiUseCase.getUsersList
         .doAsync(100)
         .onSuccess { result in
            Self.store.foundUsers = result
            work.success(result: result)
         }.onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var mapIndexToUser: Work<Int, FoundUser> { .init { [weak self] work in

      // TODO: - 2d sections mapping to 1d array error
//      let user = Self.store.foundUsers[work.unsafeInput]
      guard
         let index = work.input
      else {
         work.fail()
         return
      }
      if Self.store.foundUsers.indices.contains(index) {
         let user = Self.store.foundUsers[index]
         Self.store.recipientUsername = user.name.unwrap
         Self.store.recipientID = user.userId
         Self.store.recipientUser = user
         
//         self?.inputTextCacher.setKey("SendTransactToUserID \(user.userId)")
         
         work.success(result: user)
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var coinInputParsing: Work<String, String> { .init { [weak self] work in
      self?.coinInputParser.work
         .retainBy(self?.retainer)
         .doAsync(work.input)
         .onSuccess {
            Self.store.inputAmountText = $0
            Self.store.isCorrectCoinInput = true
            work.success(result: $0)
         }
         .onFail { (text: String) in
            Self.store.inputAmountText = ""
            Self.store.isCorrectCoinInput = false
            work.fail(text)
         }
   } }

   var reasonInputParsing: Work<String, String> { .init { [weak self] work in
      self?.reasonInputParser.work
         .retainBy(self?.retainer)
         .doAsync(work.input)
         .onSuccess {
            Self.store.inputReasonText = $0
            Self.store.isCorrectReasonInput = true
            work.success(result: $0)
         }
         .onFail { (text: String) in
            Self.store.inputReasonText = ""
            Self.store.isCorrectReasonInput = false
            work.fail(text)
         }
   } }

   lazy var reset = Out<Void> { work in
      Self.store.inputAmountText = ""
      Self.store.inputReasonText = ""
      Self.store.isCorrectCoinInput = false
      Self.store.isCorrectReasonInput = false
      Self.store.isAnonymous = false
      Self.store.images = []
      Self.store.isTagsEnabled = false
      Self.store.tags = []
      Self.store.recipientUser = nil
      work.success()
   }

   lazy var anonymousOn = Out<Void> { work in
      Self.store.isAnonymous = true
      work.success()
   }

   lazy var anonymousOff = Out<Void> { work in
      Self.store.isAnonymous = false
      work.success()
   }

   var updateAmount: Work<(String, Bool), Void> { .init { work in
      guard let input = work.input else { return }

      Self.store.inputAmountText = input.0
      Self.store.isCorrectCoinInput = input.1
      work.success()
   }.retainBy(retainer) }

   var updateReason: Work<(String, Bool), Void> { .init { work in
      guard let input = work.input else { return }
      Self.store.inputReasonText = input.0
      Self.store.isCorrectReasonInput = input.1
      work.success()
   }.retainBy(retainer) }

   var isCorrectBothInputs: Work<Void, Void> { .init { work in
      if Self.store.isCorrectCoinInput, Self.store.isCorrectReasonInput || Self.store.tags.count > 0 {
         work.success()
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var changePublicMode: In<Bool> { .init { work in
      Self.store.isPublic = work.in
      work.success()
   }.retainBy(retainer) }

   var loadStickers: Out<[Sticker]> { .init { [weak self] work in
      guard Self.store.availableStickers == nil else {
         work.fail()
         return
      }

      self?.apiUseCase.getStickers
         .doAsync()
         .onSuccess {
            Self.store.availableStickers = $0
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }}

   var loadStickerImages: GroupWork<Sticker, UIImage> { .init { work in
      let stickerLink = work.in.image
      let stickerUrl = SpasibkaEndpoints.convertToImageUrl(stickerLink)
      AF
         .request(stickerUrl)
         .responseImage { response in
            switch response.result {
            case let .success(image):
               work.success(image)
            case .failure:
               work.fail()
            }
         }
   }.retainBy(retainer) }

   var didSelectStickerIndex: In<Int> { .init { work in
      Self.store.selectedSticker = Self.store.availableStickers?[work.in]
      work.success()
   }.retainBy(retainer) }

   var removeSelectedSticker: VoidWork { .init { work in
      Self.store.selectedSticker = nil
      work.success()
   }.retainBy(retainer) }

//   lazy var inputTextCacher = TextCachableWork(cache: Asset.service.staticTextCache)
}

extension TransactWorks: ImageWorks {}
