//
//  String+Transcode.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 23.01.2023.
//

import UIKit

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}
