//
//  ChallengeGroupWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

final class ChallengeGroupTempStorage: InitProtocol {

}

final class ChallengeGroupWorks<Asset: AssetProtocol>: BaseWorks<ChallengesTempStorage, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase
}

extension ChallengeGroupWorks: CheckInternetWorks {}

extension ChallengeGroupWorks {}
