//
//  ChallengeTemplateCreateWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.07.2023.
//

import Alamofire
import StackNinja
import UIKit

final class ChallengeTemplateCreateStore: InitClassProtocol, ImageStorage {
   var indexes: [Int] = []
   
   var templateId: Int?

   var title: String = ""
   var desription: String = ""

   var images: [UIImage] = []

   var settings: ChallengeSettings?

   var scope: ChallengeTemplatesScope = .common

   var photoURL: String?

   var selectedCategories: [CategoryData] = []

   enum State {
      case createTemplate
      case updateTemplate
   }

   var state: State = .createTemplate
}

final class ChallengeTemplateCreateWorks<Asset: ASP>: BaseWorks<
   ChallengeTemplateCreateStore, Asset
> {
   private(set) lazy var apiUseCase = Asset.apiUseCase

   var saveTemplateValues: InOut<ChallengeTemplateCreateInput> { .init { work in
      guard let input = work.input else { work.fail(); return }

      switch input {
      case let .createTemplate(scope):
         Self.store.state = .createTemplate
         Self.store.scope = scope

      case let .updateTemplateWithTemplate(template, scope):
         Self.store.state = .updateTemplate
         Self.store.title = template.name.unwrap
         Self.store.desription = template.description.unwrap
         Self.store.settings?.severalReports = template.multipleReports ?? true
         Self.store.settings?.showContenders = template.showContenders ?? true
         Self.store.settings?.setCurrentChallengeTypeForName(template.challengeType)
         Self.store.templateId = template.id
         Self.store.photoURL = template.photo
         Self.store.scope = scope
         Self.store.selectedCategories = template.sections?.map {
            CategoryData(id: $0.id, name: $0.name, children: [])
         } ?? []
      }

      work.success(input)
   }.retainBy(retainer) }

   var checkAllReady: Work<Void, Bool> { .init { work in
      let ready =
         Self.store.title.isEmpty == false &&
         Self.store.desription.isEmpty == false

      work.success(ready)
   }.retainBy(retainer) }

   var setTitle: InOut<String> { .init { work in
      Self.store.title = work.in
      work.success(work.in)
   }.retainBy(retainer) }

   var titleCacher: TextCachableWork {
      .init(cache: Asset.service.staticTextCache, key: "ChallCreateTemplateTitleKey")
         .retainBy(retainer)
   }

   var setDesription: InOut<String> { .init { work in
      Self.store.desription = work.unsafeInput
      work.success(work.in)
   }.retainBy(retainer) }

   var descriptCacher: TextCachableWork {
      .init(cache: Asset.service.staticTextCache, key: "ChallCreateTemplateDescriptKey")
         .retainBy(retainer)
   }

   var createChallengeGet: VoidWork { .init { [weak self] work in
      self?.apiUseCase.createChallengeGet
         .doAsync()
         .onSuccess {
            let settings = ChallengeSettings(settings: $0, mode: .templateSettings)
            Self.store.settings = settings
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var tryLoadPhoto: Out<UIImage?> { .init { work in
      if let photo = Self.store.photoURL {
         let url = SpasibkaEndpoints.convertToImageUrl(photo)
         AF.request(url).responseImage {
            if case let .success(image) = $0.result {
               work.success(image)
            } else {
               work.success(nil)
            }
         }
      } else {
         work.success(nil)
      }
   }.retainBy(retainer) }

   var getTemplatesScope: Out<ChallengeTemplatesScope> { .init { work in
      work.success(Self.store.scope)
   }.retainBy(retainer) }
}

// MARK: - Settings

extension ChallengeTemplateCreateWorks {
   var getSavedSettings: Out<ChallengeSettings> { .init { work in
      guard let settings = Self.store.settings else {
         work.fail()
         return
      }
      work.success(settings)
   }.retainBy(retainer) }

   var getCategoriesInput: Out<CategoriesInput> { .init { work in
      work.success(.init(scope: Self.store.scope, selectedCategories: Self.store.selectedCategories))
   }.retainBy(retainer) }

   var setSelectedCategories: In<[CategoryData]> { .init { work in
      Self.store.selectedCategories = work.in
      work.success()
   }.retainBy(retainer) }

   var getSelectedCategories: Out<[CategoryData]> { .init { work in
      work.success(Self.store.selectedCategories)
   }.retainBy(retainer) }
}

extension ChallengeTemplateCreateWorks {
   var createOrUpdateTemplate: Work<Void, Void> { .init { [weak self] work in
      switch Self.store.state {
      case .createTemplate:
         self?.createChallengeTemplate
            .doAsync()
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      case .updateTemplate:
         self?.updateChallengeTemplate
            .doAsync()
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }.retainBy(retainer) }
   
   var deleteChallengeTemplate: Work<Void, Void> { .init { [weak self] work in
      guard let id = Self.store.templateId else { work.fail(); return }
      self?.apiUseCase.deleteChallengeTemplate
         .doAsync(id)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}

// MARK: - Private

extension ChallengeTemplateCreateWorks {
   private var createChallengeTemplate: Work<Void, Void> { .init { [weak self] work in
      guard let settings = Self.store.settings else { work.fail(); return }

      let resizedImage = Self.store.images.first?.sideLengthLimited(to: Config.imageSendSize)
      let showContenders = settings.selectedChallengeType == .default ? settings.showContenders.yesNo : nil
      let request = CreateChallTemplateRequest(scope: Self.store.scope.rawValue,
                                               name: Self.store.title,
                                               sections: Self.store.selectedCategories.map(\.id),
                                               showContenders: showContenders,
                                               description: Self.store.desription,
                                               challengeType: settings.selectedChallengeTypeName,
                                               multipleReports: settings.severalReports.yesNo,
                                               photo: resizedImage)

      self?.apiUseCase.createChallengeTemplate
         .doAsync(request)
         .onSuccess { _ in
            self?.titleCacher.clearCache()
            self?.descriptCacher.clearCache()
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   private var updateChallengeTemplate: Work<Void, Void> { .init { [weak self] work in
      guard let settings = Self.store.settings else { work.fail(); return }

      let resizedImage = Self.store.images.first?.sideLengthLimited(to: Config.imageSendSize)
      let showContenders = settings.selectedChallengeType == .default ? settings.showContenders.yesNo : nil
      let request = UpdateChalleneTemplateRequest(
         name: Self.store.title,
         description: Self.store.desription,
         challengeTemplate: Self.store.templateId.unwrap,
         scope: Self.store.scope.rawValue,
         sections: Self.store.selectedCategories.map(\.id),
         challengeType: settings.selectedChallengeTypeName,
         multipleReports: settings.severalReports.yesNo,
         showContenders: showContenders,
         photo: resizedImage
      )

      self?.apiUseCase.updateChallengeTemplate
         .doAsync(request)
         .onSuccess { _ in
            self?.titleCacher.clearCache()
            self?.descriptCacher.clearCache()
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}

extension ChallengeTemplateCreateWorks: ImageWorks {}
