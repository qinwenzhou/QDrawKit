//
//  LayerShape.swift
//  Drawing
//
//  Created by qinwenzhou on 2017/6/15.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class LayerShape: CAShapeLayer, Shape {
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
        if let cgpath = self.path {
            if let p = CGPath(__byStroking: cgpath,
                              transform: nil,
                              lineWidth: 30,
                              lineCap: .round,
                              lineJoin: .round,
                              miterLimit: 1) {
                return p.contains(point)
            }
        }
        return false
    }
    
    func draw(with state: DrawState, at point: CGPoint) {
        // 由子类实现具体的绘制过程
    }
}
