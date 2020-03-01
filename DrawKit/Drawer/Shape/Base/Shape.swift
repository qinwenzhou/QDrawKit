//
//  Renderer.swift
//  Drawing
//
//  Created by qinwenzhou on 2017/6/15.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

enum DrawState {
    case began
    case moved
    case ended
}

protocol Shape {
    var isShapeSelected: Bool {set get}
    
    func vertexes() -> [CGPoint]?
    func vertexContains(_ point: CGPoint) -> CGPoint?
    func shapeContains(_ point: CGPoint) -> Bool
    func draw(with state: DrawState, at point: CGPoint)
}
