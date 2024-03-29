//
//  UpdateProfileAvatarWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.12.2022.
//

import StackNinja
import UIKit

protocol UpdateProfileAvatarStorageProtocol: InitClassProtocol {
   var image: UIImage? { get set }
   var croppedImage: UIImage? { get set }
}

protocol UpdateProfileAvatarWorksProtocol: Assetable, StoringWorksProtocol where
   Store: UpdateProfileAvatarStorageProtocol,
   Asset: AssetProtocol
{
   var apiUseCase: ApiUseCase<Asset> { get }
   //
   var addImage: Work<UIImage, UIImage> { get }
   var updateAvatarForUserData: Work<UserData, Void> { get }
}

extension UpdateProfileAvatarWorksProtocol {
   // MARK: - Add avatar

   var addImage: Work<UIImage, UIImage> { .init { work in
      Self.store.image = work.unsafeInput
      work.success(result: work.unsafeInput)
   } }

   var saveCroppedImage: Work<UIImage, UIImage> { .init { work in
      Self.store.croppedImage = work.unsafeInput
      work.success(result: work.unsafeInput)
   }}

   // MARK: - Save to server
   
   var updateAvatarForUserData: Work<UserData, Void> {
      .init { [weak self] work in
         guard
            let userData = work.input,
            let avatarRequest = self?.formAvatarRequest(userData)
         else { return }

         self?.apiUseCase.updateProfileImage
            .doAsync(avatarRequest)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }.retainBy(retainer)
   }
}

private extension UpdateProfileAvatarWorksProtocol {
   func formAvatarRequest(_ userData: UserData) -> UpdateImageRequest? {
      guard
         let avatar = Self.store.image
      else { return nil }

      let request = UpdateImageRequest(token: "",
                                       id: userData.profile.id,
                                       photo: avatar,
                                       croppedPhoto: Self.store.croppedImage)
      return request
   }
}
