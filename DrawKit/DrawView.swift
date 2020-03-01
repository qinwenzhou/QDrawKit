//
//  DrawView.swift
//  Drawing
//
//  Created by zte on 2017/5/31.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

public protocol DrawViewDelegate {
    func drawViewWillBeginDrawing(_ drawView: DrawView)
    func drawViewDidEndDrawing(_ drawView: DrawView)
    func drawView(_ drawView: DrawView, didSelectBrush brush: Brush?)
}

public class DrawView: UIView {
    public var delegate: DrawViewDelegate?
    
    public var image: UIImage? {
        didSet {
            removeAllBrushes()
            _imageView.image = image
        }
    }
    private var _imageView: UIImageView!
    private var _maskDrawersContainer: UIView! // 仅收纳遮罩类型的drawer
    private var _shapeDrawersContainer: UIView! // 收纳除遮罩类型以外的所有drawer
    private var _selectedIndicatorView: UIView!
    
    private var _drawingDrawer: Drawer? // 绘制完成后就会被设为nil了。
    
    public var currentBrush: Brush?
    public var selectedBrush: Brush? {
        return _selectedBrush
    }
    private var _selectedBrush: Brush? {
        didSet {
            _showSelectedIndicatorIfNeed()
            delegate?.drawView(self, didSelectBrush: _selectedBrush)
        }
    }
    
    private var _brushTag = 0 // 唯一标识每一个brush
    private var _allBrushes = [Int: Brush]() // 存储所有已绘制的brush
    
    
    // MARK: - Init
    
    private func _init() {
        self.backgroundColor = UIColor.black
        
        _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        self.addSubview(_imageView)
        
        _maskDrawersContainer = UIView()
        _imageView.addSubview(_maskDrawersContainer)
        
        _shapeDrawersContainer = UIView()
        _imageView.addSubview(_shapeDrawersContainer)
        
        _selectedIndicatorView = UIView()
        self.addSubview(_selectedIndicatorView)

        // Gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(_onPanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_onTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    override public func layoutSubviews() {
        _imageView.frame =  self.bounds
        _maskDrawersContainer.frame = _imageView.bounds
        _shapeDrawersContainer.frame = _imageView.bounds
        _selectedIndicatorView.frame =  self.bounds
    }
    
    
    // MARK: - Save
    
    public func save() -> UIImage? {
        let s = _imageView.bounds.size
        UIGraphicsBeginImageContextWithOptions(s, false, UIScreen.main.scale);
        if let context = UIGraphicsGetCurrentContext() {
            _imageView.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: - Brush
    
    public func hadDrawed() -> Bool {
        return (_allBrushes.count > 0)
    }
    
    public func unselectedAllBrushes() {
        func _unselectedAllShapes(in container: UIView) {
            let views = container.subviews
            for v in views {
                if v is Drawer {
                    let drawer = v as! Drawer
                    if drawer.shape != nil {
                        drawer.shape!.isShapeSelected = false
                    }
                }
            }
        }
        
        _unselectedAllShapes(in: _shapeDrawersContainer)
        _unselectedAllShapes(in: _maskDrawersContainer)
        
        if _selectedBrush != nil {
            _selectedBrush = nil
        }
    }
    
    public func removeAllBrushes() {
        func _removeAllBrushes(in container: UIView) {
            let views = container.subviews
            for v in views {
                if v is Drawer {
                    let drawer = v as! Drawer
                    drawer.removeFromSuperview()
                }
            }
        }
        
        _removeAllBrushes(in: _shapeDrawersContainer)
        _removeAllBrushes(in: _maskDrawersContainer)
        _maskDrawersContainer.backgroundColor = nil
        
        _allBrushes.removeAll()
        _brushTag = 0
        
        if _selectedBrush != nil {
            _selectedBrush = nil
        }
    }
    
    public func removeBrush(_ brush: Brush) {
        if brush.tag == selectedBrush?.tag {
            _selectedBrush = nil
        }
        _allBrushes.removeValue(forKey: brush.tag)
        
        if let drawer = _drawerWithBrushTag(brush.tag) {
            drawer.removeFromSuperview()
        }
        
        // 如果不存在MaskBrush则去掉背景色
        var hasMaskBrush = false
        for (_, brush) in _allBrushes {
            if brush is MaskBrush {
                hasMaskBrush = true
            }
        }
        if !hasMaskBrush {
            _maskDrawersContainer.backgroundColor = nil
        }
    }
    
    public func updateBrush(_ brush: Brush) {
        let newBrush = brush
        if newBrush.tag == selectedBrush?.tag {
            _selectedBrush = newBrush
        }
        _allBrushes[newBrush.tag] = newBrush
        
        let drawer = _drawerWithBrushTag(newBrush.tag)
        if drawer?.shape == nil {
            return
        }
        if newBrush is ArrowBrush {
            let arrowBrush = newBrush as! ArrowBrush
            
            let arrowShape = (drawer?.shape as! ArrowShape)
            arrowShape.fillColor = arrowBrush.arrowColor?.cgColor
            arrowShape.arrowSize = arrowBrush.arrowSize
            arrowShape.hookFactor = arrowBrush.hookFactor
            
        } else if newBrush is LineBrush {
            let lineBrush = newBrush as! LineBrush
            
            let lineShape = (drawer?.shape as! LineShape)
            lineShape.strokeColor = lineBrush.lineColor?.cgColor
            lineShape.lineWidth = lineBrush.lineWidth
            
        } else if newBrush is RectBrush {
            let rectBrush = newBrush as! RectBrush
            
            let rectShape = (drawer?.shape as! RectShape)
            rectShape.strokeColor = rectBrush.lineColor?.cgColor
            rectShape.lineWidth = rectBrush.lineWidth
            
        } else if newBrush is SolidBrush {
            let solidBrush = newBrush as! SolidBrush
            
            let solidShape = (drawer?.shape as! SolidShape)
            solidShape.fillColor = solidBrush.solidColor?.cgColor
        }
    }
    
    
    // MARK: - Drawer
    
    private func _createDrawer() -> Drawer? {
        var shape: Shape?
        var drawer: Drawer?

        _brushTag += 1
        currentBrush?.tag = _brushTag
        
        if currentBrush is ArrowBrush {
            let arrowBrush = currentBrush as! ArrowBrush
            
            let arrowShape = ArrowShape(type: arrowBrush.type)
            arrowShape.fillColor = arrowBrush.arrowColor?.cgColor
            arrowShape.arrowSize = arrowBrush.arrowSize
            arrowShape.hookFactor = arrowBrush.hookFactor
            
            shape = arrowShape
            
        } else if currentBrush is LineBrush {
            let lineBrush = currentBrush as! LineBrush
            
            let lineShape = LineShape(type: lineBrush.type)
            lineShape.strokeColor = lineBrush.lineColor?.cgColor
            lineShape.lineWidth = lineBrush.lineWidth
            
            shape = lineShape

        } else if currentBrush is RectBrush {
            let rectBrush = currentBrush as! RectBrush
            
            let rectShape = RectShape(type: rectBrush.type)
            rectShape.strokeColor = rectBrush.lineColor?.cgColor
            rectShape.lineWidth = rectBrush.lineWidth
            
            shape = rectShape
            
        } else if currentBrush is SolidBrush {
            let solidBrush = currentBrush as! SolidBrush
            
            let solidShape = SolidShape(type: solidBrush.type)
            solidShape.fillColor = solidBrush.solidColor?.cgColor
            
            shape = solidShape
            
        } else if currentBrush is MaskBrush {
            let maskBrush = currentBrush as! MaskBrush
            
            let solidShape = SolidShape(type: maskBrush.type)
            
            shape = solidShape
            
        } else if currentBrush is TextBrush {
            let textBrush = currentBrush as! TextBrush
        
            let textShape = TextShape(type: textBrush.type)
            textShape.textColor = textBrush.textColor
            textShape.font = textBrush.font
            textShape.isShapeSelected = true // 文本创建时就设为选中
            _selectedBrush = currentBrush
            
            shape = textShape
        }
        
        if shape != nil {
            if currentBrush is MaskBrush {
                let maskDrawer = MaskDrawer()
                maskDrawer.maskImageView.image = _imageView.image
                maskDrawer.maskImageView.contentMode = _imageView.contentMode
                maskDrawer.shape = shape
                
                drawer = maskDrawer
                
            } else {
                let shapeDrawer = ShapeDrawer()
                shapeDrawer.shape = shape
                
                drawer = shapeDrawer
            }
        }
        drawer?.tag = _brushTag // 与brush tag对应
        
        return drawer
    }
    
    private func _drawerWithBrushTag(_ brushTag: Int) -> Drawer? {
        func _drawer(with btag: Int, in container: UIView) -> Drawer? {
            var drawer: Drawer?
            
            let views = container.subviews
            for v in views {
                if v is Drawer {
                    let drw = v as! Drawer
                    if drw.tag == brushTag {
                        drawer = drw
                    }
                }
            }
            
            return drawer
        }
        
        var drawer = _drawer(with: brushTag, in: _shapeDrawersContainer)
        if drawer == nil {
            drawer = _drawer(with: brushTag, in: _maskDrawersContainer)
        }
        
        return drawer
    }
    
    private func _drawerContained(_ point: CGPoint) -> Drawer? {
        func _drawer(contained point: CGPoint, in container: UIView) -> Drawer? {
            var drawer: Drawer?
            
            let views = container.subviews
            for v in views {
                if v is Drawer {
                    let drw = v as! Drawer
                    if let shape = drw.shape {
                        if shape.shapeContains(point) {
                            drawer = drw
                        }
                    }
                }
            }
            
            return drawer
        }
        
        var drawer: Drawer?
        
        if let brush = _selectedBrush { // 优先寻找已选中的
            if let drw = _drawerWithBrushTag(brush.tag) {
                if let shape = drw.shape {
                    if shape.shapeContains(point) ||
                        shape.vertexContains(point) != nil{
                        drawer = drw
                    }
                }
            }
        }
        
        if drawer == nil {
            drawer = _drawer(contained: point, in: _shapeDrawersContainer)
            if drawer == nil {
                drawer = _drawer(contained: point, in: _maskDrawersContainer)
            }
        }

        return drawer
    }
    
    private func _bringDrawerToFront(_ drawer: Drawer) {
        if drawer is MaskDrawer {
            _maskDrawersContainer.bringSubview(toFront: drawer)
        } else {
            _shapeDrawersContainer.bringSubview(toFront: drawer)
        }
    }

    
    // MARK: - Gesture
    
    private func _drawState(for gestureState: UIGestureRecognizerState) -> DrawState {
        if gestureState == .began {
            return .began
            
        } else if gestureState == .changed {
            return .moved
            
        } else {
            return .ended
        }
    }
    
    private func _showSelectedIndicatorIfNeed() {
        _selectedIndicatorView.layer.removeAllIndicators()
        
        if selectedBrush != nil {
            let btag = _selectedBrush!.tag
            if let selectedDrawer = _drawerWithBrushTag(btag) {
                if let vertexes = selectedDrawer.shape?.vertexes() {
                    _selectedIndicatorView.layer.showIndicators(at: vertexes)
                }
            }
        }
    }
    
    @objc private func _onPanGesture(_ sender: Any) {
        let gesture = sender as! UIGestureRecognizer
        let point = gesture.location(in: self)
        let drawState = _drawState(for: gesture.state)
        
        if drawState == .began {
            delegate?.drawViewWillBeginDrawing(self)
            
            if _drawingDrawer == nil {
                _drawingDrawer = _drawerContained(point) // 寻找包含触点的drawer
                if _drawingDrawer != nil {
                    if _drawingDrawer!.tag != _selectedBrush?.tag {
                        unselectedAllBrushes()
                    }
                    _bringDrawerToFront(_drawingDrawer!)
                    
                } else {
                    unselectedAllBrushes()
                    
                    _drawingDrawer = _createDrawer() // 如果找不到包含的就新建一个
                    if _drawingDrawer == nil {
                        print("DrawView: Drawer for current brush is nil")
                        
                    } else {
                        if _drawingDrawer is MaskDrawer {
                            _maskDrawersContainer.backgroundColor = UIColor(white: 0, alpha: 0.75)
                            _maskDrawersContainer.addSubview(_drawingDrawer!)
                            _drawingDrawer!.frame = _maskDrawersContainer.bounds
                            
                        } else {
                            _shapeDrawersContainer.addSubview(_drawingDrawer!)
                            _drawingDrawer!.frame = _shapeDrawersContainer.bounds
                        }
                        
                        _allBrushes[currentBrush!.tag] = currentBrush!
                    }
                }
            }
        }
        
        if let shape = _drawingDrawer?.shape {
            shape.draw(with: drawState, at: point)
            _showSelectedIndicatorIfNeed() // 让indicator随着shape移动
        }
        
        if drawState == .ended {
            _drawingDrawer = nil
            delegate?.drawViewDidEndDrawing(self)
        }
    }
    
    @objc private func _onTapGesture(_ sender: Any) {
        let gesture = sender as! UIGestureRecognizer
        let point = gesture.location(in: self)
        let state = gesture.state
        
        if state == .ended {
            let drawer = _drawerContained(point)
            if drawer != nil  {
                var shape = drawer!.shape
                if shape != nil {
                    if shape!.isShapeSelected {
                        shape!.isShapeSelected = false
                        _selectedBrush = nil
                        
                    } else {
                        unselectedAllBrushes()
                        _bringDrawerToFront(drawer!)
                        shape!.isShapeSelected = true
                        _selectedBrush = _allBrushes[drawer!.tag]
                    }
                }
            
            } else {
                unselectedAllBrushes()
            }
        }
    }
}
