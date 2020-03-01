//
//  Drawer.swift
//  Drawing
//
//  Created by qinwenzhou on 2017/6/15.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class ShapeDrawer: Drawer {
    override var shape: Shape? {
        willSet {
            // 移除旧的shape
            if shape is UIView {
                let v = shape as! UIView
                v.removeFromSuperview()
                
            } else if shape is CALayer {
                let l = shape as! CALayer
                l.removeFromSuperlayer()
            }
        }
        
        didSet {
            // 添加新的shape
            if shape is UIView {
                let v = shape as! UIView
                self.addSubview(v)
                
            } else if shape is CALayer {
                let l = shape as! CALayer
                self.layer.addSublayer(l)
            }
            
            self.setNeedsLayout()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shape is UIView {
            let v = shape as! UIView
            v.frame = self.bounds
            
        } else if shape is CALayer {
            let l = shape as! CALayer
            l.bounds = self.layer.bounds
            l.position = self.layer.position
        }
    }
}
