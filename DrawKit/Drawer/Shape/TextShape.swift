//
//  Text.swift
//  DrawKit
//
//  Created by qinwenzhou on 2017/7/2.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class TextShape: ViewShape, UITextViewDelegate {
    var textType: TextType = .text
    
    private var _textView: UITextView?
    
    var textColor: UIColor? {
        didSet {
            _textView?.textColor = textColor
        }
    }
    
    var font: UIFont? {
        didSet {
            _textView?.font = font
        }
    }
    
    override var isShapeSelected: Bool {
        didSet {
            if isShapeSelected {
                _textView?.layer.borderColor = UIColor.color(R: 0, G: 122, B: 255).cgColor
                _textView?.layer.borderWidth = 1
                
            } else {
                switch textType {
                case .text:
                    _textView?.layer.borderColor = nil
                    _textView?.layer.borderWidth = 0
                    
                case .borderText:
                    _textView?.layer.borderColor = textColor?.cgColor
                    _textView?.layer.borderWidth = 1
                }
            }
        }
    }

    private var _startPoint: CGPoint?
    private var _endPoint: CGPoint?
    private var _redrawPoint: CGPoint?
    private var _movingPoint: CGPoint?
    private var _isMoving = false
    
    
    // MARK: - Init
    
    init(type: TextType) {
        textType = type
        super.init(frame: .zero)
        _init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private func _init() {
        
    }
    
    
    // MARK: - Text
    
    private func _addTextView() {
        if _textView != nil {
            _removeTextView()
        }
        _textView = UITextView()
        _textView!.delegate = self
        self.addSubview(_textView!)
    }
    
    private func _removeTextView() {
        if _textView != nil {
            _textView!.resignFirstResponder()
            _textView!.removeFromSuperview()
            _textView = nil
        }
    }
    
    
    // MARK: - Draw
    
    override func vertexes() -> [CGPoint]? {
        if _textView == nil {
            return nil
        } else {
            return _textView!.frame.vertexes()
        }
    }
    
    override func shapeContains(_ point: CGPoint) -> Bool {
        if _textView == nil {
            return false
        } else {
            return _textView!.frame.contains(point)
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
        func drawRect(from: CGPoint, to: CGPoint) {
            let rect = CGRect.makeRect(with: from, to)
            _textView?.frame = rect
        }
        
        switch state {
        case .began:
            _startPoint = point
            
            if _redrawPoint != nil { // 重绘
                _redrawPoint = _textView!.frame.diagonal(for: _redrawPoint!)
            } else {
                _addTextView()
                _textView?.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            }
            
        case .moved:
            _endPoint = point
            
            if _redrawPoint == nil {
                drawRect(from: _startPoint!, to: _endPoint!)
            } else {
                drawRect(from: _redrawPoint!, to: _endPoint!)
            }
            
        case .ended:
            _startPoint = nil
            _endPoint = nil
            _redrawPoint = nil
            _textView?.backgroundColor = .clear
        }
    }
    
    private func _move(with state: DrawState, at point: CGPoint) {
        switch state {
        case .began:
            _movingPoint = point
            
        case .moved:
            let x = point.x - _movingPoint!.x
            let y = point.y - _movingPoint!.y
            let translation = CGAffineTransform(translationX: x, y: y)
            _textView!.frame.applying(translation)
            
            _movingPoint = point
            
        case .ended:
            _movingPoint = nil
            _isMoving = false
        }
    }
    
    
    // MARK: - Text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.clear
    }
}
