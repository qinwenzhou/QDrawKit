//
//  SolidRectLayer.swift
//  Drawing
//
//  Created by qinwenzhou on 2017/6/14.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class SolidShape: RectShape {
    
    // MARK: - Init
    
    override init(type: RectType) {
        super.init(type: type)
        _init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private func _init() {
        self.fillColor = UIColor.black.cgColor
    }
    
    
    // MARK: - Draw
    
    override func shapeContains(_ point: CGPoint) -> Bool {
        if let p = self.path {
            return p.contains(point)
        }
        return false
    }
}
