//
//  ChooseOrgScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import Foundation
import StackNinja

// MARK: - ChooseOrgScne

enum ChooseOrgSceneInput {
   case organizations([OrganizationAuth])
   case vkUserOrganizations([OrganizationAuth], accessToken: String)
}

final class ChooseOrgScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   DoubleStackHeaderBrandLogoVM<Asset.Design>,
   Asset,
   ChooseOrgSceneInput,
   Void
> {
   //

   private lazy var useCase = Asset.apiUseCase
   private lazy var saveLoginResultsWorks = SaveLoginResultsWorks<Asset>()

   lazy var organizationsTable = TableItemsModel()
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
      .presenters(
         Design.model.presenter.loginOrganizationCell,
         Design.model.presenter.spacer
      )

   private lazy var activity = Design.model.common.activityIndicator

   // MARK: - Start

   override func start() {
      configure()
      setState(.initial)

      guard let inputValue else { return }

      var organizations: [OrganizationAuth] = []
      var accessToken: String?
      switch inputValue {
      case let .organizations(orgs):
         organizations = orgs
      case let .vkUserOrganizations(orgs, token):
         organizations = orgs
         accessToken = token
      }

      organizationsTable.items(organizations + [SpacerItem(Grid.x64.value)])

      organizationsTable
         .on(\.didSelectItemAtIndex) { [weak self] in
            guard let self else { return }

            self.setState(.loading)
            let org = organizations[$0]
            if let accessToken {
               self.useCase.vkChooseOrg
                  .doAsync(.init(userId: org.userId, organizationId: org.organizationId, accessToken: accessToken))
                  .onFail {
                     self.setState(.initial)
                     assertionFailure("fail chooseOrganization")
                  }
                  .doMap {
                     (token: $0.token, sessionId: $0.sessionId)
                  }
                  .doNext(self.saveLoginResultsWorks.saveLoginResults)
                  .doVoidNext(self.saveLoginResultsWorks.setFcmToken)
                  .onSuccess {
                     Asset.router?.route(.presentInitial, scene: \.mainMenu)
                     Asset.router?.route(.presentInitial, scene: \.tabBar)
                  }
            } else {
               self.useCase.chooseOrganization
                  .doAsync(org)
                  .onSuccess {
                     let authResult = AuthResult(
                        xId: $0.xId,
                        xCode: $0.xCode,
                        account: $0.account,
                        organizationId: String(org.organizationId)
                     )
                     self.setState(.initial)
                     let userName = UserDefaults.standard.loadValue(forKey: .userPrivacyAppliedForUserName) ?? ""
                     Asset.router?.route(
                        .push,
                        scene: \.verify,
                        payload: .existUser(authResult: authResult, userName: userName, sharedKey: nil)
                     )
                  }
                  .onFail {
                     self.setState(.initial)
                     assertionFailure("fail chooseOrganization")
                  }
            }
         }
   }
}

extension ChooseOrgScene: StateMachine {
   enum ChooseState {
      case initial
      case loading
   }

   func setState(_ state: ChooseState) {
      switch state {
      case .initial:
         organizationsTable.userInterractionEnabled(true)
         organizationsTable.alpha(1)
         activity.hidden(true)
      case .loading:
         organizationsTable.userInterractionEnabled(false)
         organizationsTable.alpha(0.5)
         activity.hidden(false)
      }
   }
}

// MARK: - Configure presenting

private extension ChooseOrgScene {
   func configure() {
      mainVM.header
         .text(Design.text.chooseOrganization)
      mainVM.bodyStack
         .arrangedModels([
            organizationsTable,
            activity,
            Spacer(),
         ])
   }
}
