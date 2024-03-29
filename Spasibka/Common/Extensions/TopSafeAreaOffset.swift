//
//  TopSafeAreaOffset.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.02.2024.
//

import UIKit

func topSafeAreaInset() -> CGFloat {
   UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 32
}
