//
//  ViewShape.swift
//  DrawKit
//
//  Created by qinwenzhou on 2017/7/2.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class ViewShape: UIView, Shape {
    var isShapeSelected = false
    
    
    func vertexes() -> [CGPoint]? {
        return nil
    }
    
    func vertexContains(_ point: CGPoint) -> CGPoint? {
        if let vs = vertexes() {
            for v in vs {
                if v.contains(point) {
                    return v
                }
            }
        }
        return nil
    }
    
    func shapeContains(_ point: CGPoint) -> Bool {
        return false
    }
    
    func draw(with state: DrawState, at point: CGPoint) {
        // 由子类实现具体的绘制过程
    }
}
