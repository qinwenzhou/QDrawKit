//
//  RectLayer.swift
//  Drawing
//
//  Created by zte on 2017/6/12.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class RectShape: LayerShape {
    private var _rectType: RectType = .oval
    var rectType: RectType {
        return _rectType
    }
    
    private var _startPoint: CGPoint?
    private var _endPoint: CGPoint?
    private var _redrawPoint: CGPoint?
    private var _movingPoint: CGPoint?
    private var _isMoving = false
    

    // MARK: - Init
    
    init(type: RectType) {
        _rectType = type
        super.init()
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
        self.fillColor = nil
    }
    
    
    // MARK: - Draw
    
    override func vertexes() -> [CGPoint]? {
        if let p = self.path {
            return p.boundingBoxOfPath.vertexes()
        } else {
            return nil
        }
    }
    
    private func _drawRect(from: CGPoint, to: CGPoint) {
        let rect = CGRect.makeRect(with: from, to)
        switch _rectType {
        case .oval:
            self.path = UIBezierPath(ovalIn: rect).cgPath
            
        case .rect:
            self.path = UIBezierPath(rect: rect).cgPath
            
        case .roundRect:
            let radius: CGFloat = min(rect.size.width/4, 20.0)
            self.path = UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
        }
    }
    
    override func draw(with state: DrawState, at point: CGPoint) {
        super.draw(with: state, at: point)
        
        if state == .began {
            _redrawPoint = vertexContains(point)
            if _redrawPoint != nil && isShapeSelected { // 重绘
                _isMoving = false
            } else {
                _redrawPoint = nil
                _isMoving = shapeContains(point)
            }
        }
        
        if !_isMoving {
            _draw(with: state, at: point)
        } else {
            _move(with: state, at: point)
        }
    }
    
    private func _draw(with state: DrawState, at point: CGPoint) {
        switch state {
        case .began:
            _startPoint = point
            
            if _redrawPoint != nil { // 重绘
                _redrawPoint = self.path!.boundingBoxOfPath.diagonal(for: _redrawPoint!)
            }
            
        case .moved:
            _endPoint = point
            
            if _redrawPoint == nil {
                _drawRect(from: _startPoint!, to: _endPoint!)
            } else {
                _drawRect(from: _redrawPoint!, to: _endPoint!)
            }
            
        case .ended:
            _startPoint = nil
            _endPoint = nil
            _redrawPoint = nil
        }
    }
    
    private func _move(with state: DrawState, at point: CGPoint) {
        switch state {
        case .began:
            _movingPoint = point
            
        case .moved:
            let x = point.x - _movingPoint!.x
            let y = point.y - _movingPoint!.y
            var translation = CGAffineTransform(translationX: x, y: y)
            self.path = self.path?.copy(using: &translation)
            
            _movingPoint = point

        case .ended:
            _movingPoint = nil
            _isMoving = false
        }
    }
}
