//
//  ProfileStorageProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.12.2022.
//

import StackNinja

protocol ProfileStorageProtocol: InitClassProtocol {
   var userData: UserData? { get set }
}
