//
//  CGRect+Utils.swift
//  UIDrawKit
//
//  Created by qwz on 2016/8/20.
//  Copyright © 2016年 qwz. All rights reserved.
//

import UIKit

extension CGRect {
    // 根据两个对角点创建矩形
    static func makeRect(with start: CGPoint, _ end: CGPoint) -> CGRect {
        let leftTop = CGPoint(x: (start.x <= end.x) ? start.x : end.x,
                              y: (start.y <= end.y) ? start.y : end.y)
        
        let rightBottom = CGPoint(x: (start.x >= end.x) ? start.x : end.x,
                                  y: (start.y >= end.y) ? start.y : end.y)
        
        let size = CGSize(width: abs(rightBottom.x - leftTop.x),
                          height: abs(rightBottom.y - leftTop.y))
        
        return CGRect(origin: leftTop, size: size)
    }
    
    // 获取四个顶点
    func vertexes() -> [CGPoint] {
        let lt = CGPoint(x: origin.x, y: origin.y)
        let lb = CGPoint(x: origin.x, y: origin.y + size.height)
        let rb = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
        let rt = CGPoint(x: origin.x + size.width, y: origin.y)
        return [lt, lb, rb, rt]
    }
    
    // 获取对角点
    func diagonal(for vertex: CGPoint) -> CGPoint {
        return CGPoint(x: (vertex.x >= maxX) ? maxX - width : maxX,
                       y: (vertex.y >= maxY) ? maxY - height : maxY)
    }
    
    // 获取中点
    func center() -> CGPoint {
        return CGPoint(x: origin.x + width/2.0, y: origin.y + height/2.0)
    }
    
    
    // 获取矩形与直线的交点
    // begin
    
    // 线段
    private struct Line {
        var point1: CGPoint
        var point2: CGPoint
    }
    
    // 判断两条线段是否相交
    private func isIntersected(for line1: Line, _ line2: Line) -> Bool {
        let p1 = line1.point1, p2 = line1.point2
        let p3 = line2.point1, p4 = line2.point2
        let denominator = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
        
        // In this case the lines are parallel so we assume they don't intersect~
        if denominator == 0.0 {
            return false
        }
        
        let ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denominator
        let ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denominator
        
        if ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0 {
            return true
        }  
        return false
    }
    
    // 获取两条直线的交点
    private func cross(for line1: Line, _ line2: Line) -> CGPoint {
        let u1 = line1.point1, u2 = line1.point2
        let v1 = line2.point1, v2 = line2.point2
        
        var ret = u1
        let k1 = ((u1.x-v1.x)*(v1.y-v2.y) - (u1.y-v1.y)*(v1.x-v2.x))
        let k2 = ((u1.x-u2.x)*(v1.y-v2.y) - (u1.y-u2.y)*(v1.x-v2.x))
        let t = k1 / k2
        ret.x += (u2.x - u1.x) * t
        ret.y += (u2.y - u1.y) * t
        return ret
    }
    
    // 获取从矩形中心引出的直线与矩形的交点
    func crossForCenterLine(endAt point: CGPoint) -> CGPoint? {
        let vertexes = self.vertexes()
        let edgeLine1 = Line(point1: vertexes[0], point2: vertexes[1])
        let edgeLine2 = Line(point1: vertexes[1], point2: vertexes[2])
        let edgeLine3 = Line(point1: vertexes[2], point2: vertexes[3])
        let edgeLine4 = Line(point1: vertexes[3], point2: vertexes[0])
        
        let centerLine = Line(point1: self.center(), point2: point)
        
        if isIntersected(for: edgeLine1, centerLine) {
            return cross(for: edgeLine1, centerLine)
            
        } else if isIntersected(for: edgeLine2, centerLine) {
            return cross(for: edgeLine2, centerLine)
            
        } else if isIntersected(for: edgeLine3, centerLine) {
            return cross(for: edgeLine3, centerLine)
            
        } else if isIntersected(for: edgeLine4, centerLine) {
            return cross(for: edgeLine4, centerLine)
        }
        return nil
    }
    
    // end
    /////////////
}
