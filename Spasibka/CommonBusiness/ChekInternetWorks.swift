//
//  ChekInternetWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.11.2022.
//

import StackNinja

protocol CheckInternetWorks {}

extension CheckInternetWorks {
   var checkInternet: Work<Void, Void> { InetCheckWorker().work }
}
