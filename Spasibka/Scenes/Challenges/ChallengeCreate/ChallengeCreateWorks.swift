//
//  ChallengeCreateWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.10.2022.
//

import StackNinja
import UIKit

protocol ChallengeCreateWorksProtocol {}

final class ChallengeCreateWorksStore: InitProtocol, SortableImageStorage {

   var images: [UIImage] = [] {
      didSet {
         images = []
      }
   }
   var indexes: [Int] = []

//   var imageLinks: [String] = []
//   var imageIndexes: [Int] = []
//   
   let maxImagesCount: Int = 10
   var fileList: [FileList] = []

   var title: String = ""
   var desription: String = ""
   var prizeFund: String = ""
   var prizePlace: String = ""

   var startDate: Date?
   var finishDate: Date?

   var settings: ChallengeSettings?
   var uneditedSettings: ChallengeSettings?

   var templateId: Int?

   var scope: ChallengeTemplatesScope = .common

   var isEditingMode: Bool = false

   var challengeId: Int?

   var uneditedChallenge: Challenge?

   var isBalanceHidden: Bool = true
}

final class ChallengeCreateWorks<Asset: AssetProtocol>: BaseWorks<ChallengeCreateWorksStore, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase
}

extension ChallengeCreateWorks: ChallengeCreateWorksProtocol {
   var checkAllReady: Work<Void, Bool> { .init { work in
      if Self.store.isEditingMode {
         let ready = Self.store.title.isEmpty == false
         work.success(ready)
      } else {
         let ready =
            Self.store.title.isEmpty == false &&
            Self.store.prizeFund.isEmpty == false &&
            Self.store.prizePlace.isEmpty == false
         work.success(ready)
      }

   }.retainBy(retainer) }

   var setTitle: InOut<String> { .init { work in
      Self.store.title = work.in
      work.success(work.in)
   }.retainBy(retainer) }

   var titleCacher: TextCachableWork {
      .init(cache: Asset.service.staticTextCache, key: "ChallCreateTitleKey")
         .retainBy(retainer)
   }

   var setDesription: InOut<String> { .init { work in
      Self.store.desription = work.unsafeInput
      work.success(work.in)
   }.retainBy(retainer) }

   var descriptCacher: TextCachableWork {
      .init(cache: Asset.service.staticTextCache, key: "ChallCreateDescriptKey")
         .retainBy(retainer)
   }

   var setPrizeFund: Work<String, Void> { .init { work in
      Self.store.prizeFund = work.unsafeInput
      work.success()
   }.retainBy(retainer) }

   var setStartDate: Work<Date, Date> { .init { work in
      Self.store.startDate = work.unsafeInput
      work.success(work.unsafeInput)
   }.retainBy(retainer) }

   var clearStartDate: VoidWork { .init { work in
      Self.store.startDate = nil
      work.success()
   }.retainBy(retainer) }

   var setFinishDate: Work<Date, Date> { .init { work in
      Self.store.finishDate = work.unsafeInput
      work.success(work.unsafeInput)
   }.retainBy(retainer) }

   var clearFinishDate: VoidWork { .init { work in
      Self.store.finishDate = nil
      work.success()
   }.retainBy(retainer) }

   var setPrizePlace: Work<String, Void> { .init { work in
      Self.store.prizePlace = work.unsafeInput
      work.success()
   }.retainBy(retainer) }

   var saveTemplateValues: In<ChallengeCreateInput>.Out<ChallengeCreateInput> { .init { [weak self] work in
      guard let self, let input = work.input else { work.fail(); return }

      switch input {
      case .createChallenge:
         break
      case let .createChallengeWithTemplate(template):
         Self.store.title = template.name.unwrap
         Self.store.desription = template.description.unwrap
         Self.store.settings?.severalReports = template.multipleReports ?? true
         Self.store.settings?.showContenders = template.showContenders ?? true
         Self.store.settings?.setCurrentChallengeTypeForName(template.challengeType)
      case let .editChallenge(value):
         Self.store.title = value.name.unwrap
         Self.store.desription = value.description.unwrap
         Self.store.settings?.severalReports = value.severalReports ?? true
         Self.store.settings?.showContenders = value.showContenders ?? true
         Self.store.settings?.setCurrentChallengeTypeForName(value.algorithmName)
         Self.store.isEditingMode = true
         Self.store.challengeId = value.id
         Self.store.uneditedChallenge = value
         Self.store.uneditedSettings?.severalReports = value.severalReports ?? true
         Self.store.uneditedSettings?.showContenders = value.showContenders ?? true
         Self.store.uneditedSettings?.setCurrentChallengeTypeForName(value.algorithmName)
//         Self.store.imageLinks = value.photos ?? []
//         Self.store.imageIndexes = self.takeIndexes(Self.store.imageLinks) ?? []
         Self.store.prizeFund = String(value.fund)
         Self.store.fileList = self.makeFileListForCurrentPhotos(value.photos ?? [])
      }

      work.success(input)
   }.retainBy(retainer) }

   // MARK: - Create chall

   var createChallenge: Work<Void, Void> { .init { [weak self] work in
      guard let settings = Self.store.settings else { work.fail(); return }

      var resizedImages: [UIImage]?
      if Self.store.images.count > 0 {
         resizedImages = []
      }
      for image in Self.store.images {
         resizedImages?.append(image.sideLengthLimited(to: Config.imageSendSize))
      }

      let showParticipants = settings.selectedChallengeTypeName == "voting" ? nil : settings.showContenders.yesNo
      let body = ChallengeRequestBody(
         name: Self.store.title,
         description: Self.store.desription,
         startAt: Self.store.startDate?.convertToString(.yyyyMMddTHHmmssZZZZZ, abbreviation: .UTC),
         endAt: Self.store.finishDate?.convertToString(.yyyyMMddTHHmmssZZZZZ, abbreviation: .UTC),
         startBalance: Int(Self.store.prizeFund).unwrap,
         photo: resizedImages,
         parameterId: 2,
         parameterValue: Int(Self.store.prizePlace),
         challengeType: settings.selectedChallengeTypeName,
         showParticipants: showParticipants,
         severalReports: settings.severalReports.yesNo,
         accountId: settings.payerAccountId
      )
      if Self.store.isEditingMode == false {
         self?.apiUseCase.createChallenge
            .doAsync(body)
            .onSuccess {
               self?.titleCacher.clearCache()
               self?.descriptCacher.clearCache()
               work.success()
            }
            .onFail {
               work.fail()
            }
      } else {
         guard let id = Self.store.challengeId else { work.fail(); return }

         let showParticipants = settings.selectedChallengeTypeName == "voting" ? nil : settings.showContenders
         let body = ChallengeEditRequest(name: Self.store.title,
                                         description: Self.store.desription,
                                         startAt: Self.store.startDate?.convertToString(.yyyyMMddTHHmmssZZZZZ, abbreviation: .UTC),
                                         endAt: Self.store.finishDate?.convertToString(.yyyyMMddTHHmmssZZZZZ, abbreviation: .UTC),
                                         startBalance: Int(Self.store.prizeFund).unwrap,
                                         accountId: settings.payerAccountId,
                                         challengeType: settings.selectedChallengeTypeName,
                                         multipleReports: settings.severalReports,
                                         winnersCount: Int(Self.store.prizePlace),
                                         showContenders: showParticipants,
                                         fileList: Self.store.fileList)

         var newBody = self?.takeEditedFields(old: Self.store.uneditedChallenge,
                                              new: body,
                                              settingsOld: Self.store.uneditedSettings)

         if Self.store.uneditedChallenge?.challengeCondition == .A, Self.store.uneditedChallenge?.approvedReportsAmount ?? 0 > 0 || Self.store.uneditedChallenge?.participantsTotal ?? 0 > 0 {
            newBody = ChallengeEditRequest(name: Self.store.title,
                                           description: Self.store.desription)
         }

         let request = (id, newBody)
         self?.apiUseCase.updateChallenge
            .doAsync(request as? (Int, ChallengeEditRequest))
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }

   }.retainBy(retainer) }

   var loadCreateChallengeSettings: VoidWork { .init { [weak self] work in
      self?.apiUseCase.createChallengeGet
         .doAsync()
         .onSuccess {
            let settings = ChallengeSettings(settings: $0, mode: .challengeSettings)
            Self.store.settings = settings
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getSavedSettings: Out<ChallengeSettings> { .init { work in
      guard let settings = Self.store.settings else {
         work.fail()
         return
      }
      work.success(settings)
   }.retainBy(retainer) }

   var deleteChallenge: In<Void>.Out<Void> { .init { [weak self] work in
      guard let id = Self.store.challengeId else { work.fail(); return }

      self?.apiUseCase.deleteChallenge
         .doAsync(id)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   private func takeEditedFields(old: Challenge?, new: ChallengeEditRequest, settingsOld: ChallengeSettings?) -> ChallengeEditRequest {
      var name: String?
      var description: String?
      var startAt: String?
      var endAt: String?
      var startBalance: Int?
      var accountId: Int?
      var challengeType: String?
      var severalReports: Bool?
      var winnersCount: Int?
      var showContenders: Bool?

      if old?.name != new.name { name = new.name }
      if old?.description != new.description { description = new.description }
      if old?.startAt != new.startAt { startAt = new.startAt }
      if old?.endAt != new.endAt { endAt = new.endAt }
      if old?.startBalance != new.startBalance { startBalance = new.startBalance }
      if old?.severalReports != new.multipleReports { severalReports = new.multipleReports }
      if old?.winnersCount != new.winnersCount { winnersCount = new.winnersCount }
      if old?.showContenders != new.showContenders { showContenders = new.showContenders }

      if Self.store.isBalanceHidden == false { accountId = new.accountId }

      if settingsOld?.selectedChallengeTypeName != new.challengeType { challengeType = new.challengeType }

      var fileList: [FileList] = Self.store.fileList

      let request = ChallengeEditRequest(
         name: name,
         description: description,
         startAt: startAt,
         endAt: endAt,
         startBalance: startBalance,
         accountId: accountId,
         challengeType: challengeType,
         multipleReports: severalReports,
         winnersCount: winnersCount,
         showContenders: showContenders,
         fileList: fileList
      )
      return request
   }

   private func makeFileListForCurrentPhotos(_ photos: [String]) -> [FileList] {
      photos.enumerated().compactMap { index, photo in
         getImageIndexFromImageLink(photo).map { FileList(sortIndex: index + 1, index: $0, filename: nil) }
      }
   }
   
   private func getImageIndexFromImageLink(_ link: String) -> Int? {
      guard let range = link.range(of: "/image/") else { return nil }
      
      return Int(String(link.dropLast()[range.upperBound...]))
   }
}

extension ChallengeCreateWorks: SortableImageWorks {}

extension ChallengeCreateWorks {
   var changeBalanceTypeIndex: In<Int> { .init { work in
      Self.store.settings?.selectedAccountTypeIndex = work.in
      work.success()
   }}

   var hideStartDate: In<Bool>.Out<Bool> { .init { work in
      guard let flag = work.input else { work.fail(); return }
      Self.store.startDate = flag == false ? nil : Self.store.startDate
      work.success(flag)
   }.retainBy(retainer) }

   var hideBalanceAccount: In<Bool>.Out<Bool> { .init { work in
      guard let flag = work.input else { work.fail(); return }
      Self.store.isBalanceHidden = !flag
      work.success(flag)
   }.retainBy(retainer) }
}
