//
//  UIColor+Utils.swift
//  drawing
//
//  Created by zte on 16/8/15.
//  Copyright © 2016年 qwz. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat = 1.0) -> UIColor {
        return UIColor(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: A)
    }
    
    func isTheSame(color: UIColor) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var sr: CGFloat = 0, sg: CGFloat = 0, sb: CGFloat = 0, sa: CGFloat = 0
        self.getRed(&sr, green: &sg, blue: &sb, alpha: &sa)
        
        return (r == sr && g == sg && b == sb && a == sa)
    }
}
