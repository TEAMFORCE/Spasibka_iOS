//
//  ChallengeCellInfoBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.11.2022.
//

import StackNinja

final class ChallengeCellInfoBlock:
   Stack<TitleBodyY>
   .D<TitleBodyY>
   .D2<TitleBodyY>
   .D3<TitleBodyY>
   .Ninja
{
   override func start() {
      super.start()

      alignment(.top)
      distribution(.equalSpacing)
   }
}
