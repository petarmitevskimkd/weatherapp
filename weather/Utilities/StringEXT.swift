//
//  StringEXT.swift
//  weather
//
//  Created by Telekom MK on 7/29/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation
import UIKit

extension String{
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
}
