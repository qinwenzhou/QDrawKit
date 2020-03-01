//
//  CGPoint+Utils.swift
//  DrawKit
//
//  Created by qwz on 2016/10/1.
//  Copyright © 2016年 qwz. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func contains(_ point: CGPoint) -> Bool {
        let size: CGFloat = 50
        let r = CGRect(x: self.x-size/2, y: self.y-size/2, width: size, height: size)
        return r.contains(point)
    }
}
