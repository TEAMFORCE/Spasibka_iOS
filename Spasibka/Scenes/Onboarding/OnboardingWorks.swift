//
//  OnboardingWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

final class OnboardingStore: InitClassProtocol {
   var userName: String = ""
   var createCommunityName: String = ""
   var joinCommunitySharedKey: String = ""
}

final class OnboardingWorks<Asset: ASP>: BaseWorks<OnboardingStore, Asset>, CreateCommunityWorksProtocol {
   private(set) lazy var apiUseCase = Asset.apiUseCase

   var setUserName: In<String> { .init {
      Self.store.userName = $0.in
      $0.success()
   }}

   var updateCreateCommunityName: In<String> { .init {
      Self.store.createCommunityName = $0.in
      $0.success()
   }}

   var updateJoinCommunitySharedKey: In<String> { .init {
      Self.store.joinCommunitySharedKey = $0.in
      $0.success()
   }}

   var getCommunityName: Out<String> { .init {
      $0.success(Self.store.createCommunityName)
   }}

   var getUserName: Out<String> { .init {
      $0.success(Self.store.userName)
   }}

   var getSharedKey: Out<String> { .init {
      $0.success(Self.store.joinCommunitySharedKey)
   }}
}

