//
//  UIColorEXT.swift
//  weather
//
//  Created by Telekom MK on 7/23/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "IRC")
        assert(green >= 0 && green <= 255, "IGC")
        assert(blue >= 0 && blue <= 255, "IBC")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
