//
//  BrandSettings.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.06.2023.
//

import Alamofire
import ReactiveWorks
import UIKit

enum BrandImageKey: String, CaseIterable {
   case loginLogo
   case smallLogo
   case menuLogo
}

enum PluralCase {
   case forSum(Int, case: Cases)
   case forForm(PluralForms.CaseForms)
}

final class BrandSettings {
   static let shared: BrandSettings = .init()

   var updateSettingsWork: In<OrganizationBrandSettings> {
      .init { [weak self] work in
         let settings = work.in

         self?.storeBrandSettingsForOrganization(settings)
         self?.organizationBrandSettings = settings
         self?.configure()

         let logos = [
            BrandImage(
               url: SpasibkaEndpoints.tryConvertToImageUrl(settings.loginLogo ?? settings.photo2),
               imageKey: BrandImageKey.loginLogo.rawValue
            ),
            BrandImage(
               url: SpasibkaEndpoints.tryConvertToImageUrl(settings.smallLogo ?? settings.photo),
               imageKey: BrandImageKey.smallLogo.rawValue
            ),
            BrandImage(
               url: SpasibkaEndpoints.tryConvertToImageUrl(settings.menuLogo ?? settings.photo2),
               imageKey: BrandImageKey.menuLogo.rawValue
            ),
         ]

         self?.imageManager.loadBrandImagesWork
            .doAsync(logos)
            .onSuccess {
               work.success()
            }
      }
   }

   func pluralCurrency(_ pluralCase: PluralCase) -> String {
      switch pluralCase {
      case let .forSum(sum, forCase):
         return pluralCurrencyManager.pluralCurrency(sum: sum, case: forCase)
      case let .forForm(form):
         return pluralCurrencyManager.pluralCurrencyForForm(form)
      }
   }

   func brandImageForKey(_ key: BrandImageKey) -> UIImage? {
      imageManager.imageForKey(key.rawValue)
   }

   func clear() {
      ColorToken.applyDefaultColors()
      imageManager.clearForKeys(BrandImageKey.allCases.map(\.rawValue))
   }

   // MARK: - Private

   private let imageManager = BrandImageManager(fileStorage: ImageFileStorage())
   private let pluralCurrencyManager = PluralCurrencyManager()

   private init() {
      organizationBrandSettings = getStoredBrandSettingsForOrganization()
      configure()
   }

   private func configure() {
      pluralCurrencyManager.updatePluralForms(organizationBrandSettings?.bonusName)
      if Toggle.isColorBrandingDisabled {
         ColorToken.applyDefaultColors()
      } else {
         ColorToken.updateColorScheme(organizationBrandSettings?.colorsJSON)
      }
      ProductionAsset.router?.initColors()
   }

   private var organizationBrandSettings: OrganizationBrandSettings?

   private func getStoredBrandSettingsForOrganization() -> OrganizationBrandSettings? {
      let brandSettings: OrganizationBrandSettings? = UserDefaults.standard.loadValue(forKey: .organizationBrandConfiguration)
      return brandSettings
   }

   private func storeBrandSettingsForOrganization(_ settings: OrganizationBrandSettings) {
      UserDefaults.standard.saveValue(settings, forKey: .organizationBrandConfiguration)
   }
}
