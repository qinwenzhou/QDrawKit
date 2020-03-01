//
//  ArrowLayer.swift
//  Drawing
//
//  Created by zte on 2017/6/12.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class ArrowShape: LayerShape {
    private var _arrowType: ArrowType = .cone
    var arrowType: ArrowType {
        return _arrowType
    }
    
    var arrowSize: CGFloat = 15 {
        didSet {
            _redrawArrow()
        }
    }
    
    var hookFactor: CGFloat = 0.2 {
        didSet {
            _redrawArrow()
        }
    }
    
    private var _startPoint: CGPoint?
    var startPoint: CGPoint? {
        return _startPoint
    }
    
    private var _endPoint: CGPoint?
    var endPoint: CGPoint? {
        return _endPoint
    }
    
    private var _movingPoint: CGPoint?
    private var _isMoving = false
    private var _isRedrawHeader: Bool?
    
    
    // MARK: - Init
    
    init(type: ArrowType) {
        _arrowType = type
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
        self.shadowOpacity = 1.0
        self.shadowRadius = 1.0
        self.shadowOffset = CGSize(width: 1.0, height: 0)
    }
    
    
    // MARK: - Draw
    
    override func vertexes() -> [CGPoint]? {
        return (_startPoint != nil && _endPoint != nil) ? [_startPoint!, _endPoint!] : nil
    }
    
    private func _redrawArrow() {
        if _startPoint != nil && _endPoint != nil {
            _drawArrow(from: _startPoint!, to: _endPoint!)
        }
    }
    
    private func _drawArrow(from: CGPoint, to: CGPoint) {
        _startPoint = from
        _endPoint = to
        
        let length = hypot(_endPoint!.x - _startPoint!.x, _endPoint!.y - _startPoint!.y)
        let size = max(3, min(arrowSize, arrowSize * length / arrowSize*0.8))
        
        switch _arrowType {
        case .cone:
            self.path = UIBezierPath.arrow(from: _startPoint!,
                                           to: _endPoint!,
                                           tailWidth: min(size*0.1, 3),
                                           tailHeadWidth: size*0.4,
                                           headWidth: size,
                                           headLength: size*0.8,
                                           hookFactor: hookFactor).cgPath
            
        case .line:
            self.path = UIBezierPath.arrow(from: _startPoint!,
                                           to: _endPoint!,
                                           tailWidth: size*0.25,
                                           tailHeadWidth: size*0.25,
                                           headWidth: size,
                                           headLength: size*0.8,
                                           hookFactor: 0).cgPath
        }
    }
    
    override func draw(with state: DrawState, at point: CGPoint) {
        super.draw(with: state, at: point)
        
        if state == .began {
            let redrawPoint = vertexContains(point)
            if redrawPoint != nil && isShapeSelected { // 重绘
                _isRedrawHeader = redrawPoint!.equalTo(_startPoint!)
                _isMoving = false
            } else {
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
            if _isRedrawHeader == nil {
                _startPoint = point
            }
            
        case .moved:
            if _isRedrawHeader != nil && _isRedrawHeader! {
                _drawArrow(from: point, to: _endPoint!) // 头部重绘
            } else {
                _drawArrow(from: _startPoint!, to: point)
            }
            
        case .ended:
            _isRedrawHeader = nil
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
            _startPoint = _startPoint?.applying(translation)
            _endPoint = _endPoint?.applying(translation)
            _movingPoint = point

        case.ended:
            _movingPoint = nil
            _isMoving = false
        }
    }
}
