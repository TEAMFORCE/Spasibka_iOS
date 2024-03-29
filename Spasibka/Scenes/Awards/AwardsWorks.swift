//
//  AwardsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2023.
//

import StackNinja

final class AwardsTempStorage: InitClassProtocol {}

final class AwardsWorks<Asset: ASP>: BaseWorks<AwardsTempStorage, Asset> {}
