//
//  UIBezierPath.swift
//  UIDrawKit
//
//  Created by qwz on 2016/8/20.
//  Copyright © 2016年 qwz. All rights reserved.
//

import UIKit

extension UIBezierPath {
    // 详细请查看：http://stackoverflow.com/questions/13528898/how-can-i-draw-an-arrow-using-core-graphics
    // 有关箭头绘制的参考：https://gist.github.com/mayoff/4152776
    class func arrow(from start: CGPoint,
                     to end: CGPoint,
                     tailWidth: CGFloat,
                     tailHeadWidth: CGFloat,
                     headWidth: CGFloat,
                     headLength: CGFloat,
                     hookFactor: CGFloat) -> Self {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        let tailLengthOffset = headLength * hookFactor
        
        let p0 = p(0, tailWidth / 2)
        let p1 = p(tailLength + tailLengthOffset, tailHeadWidth/2)
        let p2 = p(tailLength, headWidth / 2)
        let p3 = p(length, 0)
        let p4 = p(tailLength, -headWidth / 2)
        let p5 = p(tailLength + tailLengthOffset, -tailHeadWidth/2)
        let p6 = p(0, -tailWidth / 2)
        let vertexes = [p0, p1, p2, p3, p4, p5, p6]
        
        let path = UIBezierPath()
        path.move(to: p0)
        for v in vertexes {
            path.addLine(to: v)
        }
        path.addQuadCurve(to: p0, controlPoint: p(-tailWidth * 0.6, 0))
        path.close()
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        path.apply(transform)
        
        return self.init(cgPath: path.cgPath)
    }
}
