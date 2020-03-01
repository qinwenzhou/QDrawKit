//
//  LineLayer.swift
//  Drawing
//
//  Created by zte on 2017/6/12.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class LineShape: LayerShape {
    private var _lineType: LineType = .track
    var lineType: LineType {
        return _lineType
    }
    
    private var _linePath: UIBezierPath?
    
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
    
    
    // MARK: - Init
    
    init(type: LineType) {
        _lineType = type
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
        self.lineCap = kCALineCapRound
        self.lineJoin = kCALineJoinRound
        self.fillColor = nil
    }
    
    
    // MARK: - Draw
    
    override func vertexes() -> [CGPoint]? {
        return _endPoint != nil ? [_endPoint!] : nil
    }
    
    override func draw(with state: DrawState, at point: CGPoint) {
        super.draw(with: state, at: point)
        
        if state == .began {
            let redrawPoint = vertexContains(point)
            if redrawPoint != nil && isShapeSelected {
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
            if self.path != nil {
                _linePath = UIBezierPath(cgPath: self.path!)
            } else {
                _startPoint = point
                _linePath = UIBezierPath()
                _linePath!.move(to: _startPoint!)
            }
            
        case .moved:
            _endPoint = point
            
            if _lineType == .straight {
                _linePath?.removeAllPoints()
                _linePath?.move(to: _startPoint!)
            }
            _linePath?.addLine(to: _endPoint!)
            
            self.path = _linePath?.cgPath
            
        case .ended:
            _linePath = nil
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
            
        case .ended:
            _movingPoint = nil
            _isMoving = false
        }
    }
}
