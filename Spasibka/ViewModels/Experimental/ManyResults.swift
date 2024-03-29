//
//  ManyResults.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.10.2022.
//

import Foundation

// MARK: - Results

enum Result1<Load1> {
   case result1(Load1)
}

enum Result2<Load1, Load2> {
   case result1(Load1)
   case result2(Load2)
}

enum Result3<Load1, Load2, Load3> {
   case result1(Load1)
   case result2(Load2)
   case result3(Load3)
}

enum Result4<Load1, Load2, Load3, Load4> {
   case result1(Load1)
   case result2(Load2)
   case result3(Load3)
   case result4(Load4)
}

enum Result5<Load1, Load2, Load3, Load4, Load5> {
   case result1(Load1)
   case result2(Load2)
   case result3(Load3)
   case result4(Load4)
   case result5(Load5)
}

enum Result6<Load1, Load2, Load3, Load4, Load5, Load6> {
   case result1(Load1)
   case result2(Load2)
   case result3(Load3)
   case result4(Load4)
   case result5(Load5)
   case result6(Load6)
}

enum Result7<Load1, Load2, Load3, Load4, Load5, Load6, Load7> {
   case result1(Load1)
   case result2(Load2)
   case result3(Load3)
   case result4(Load4)
   case result5(Load5)
   case result6(Load6)
   case result7(Load7)
}
