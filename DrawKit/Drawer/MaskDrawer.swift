//
//  MaskDrawer.swift
//  Drawing
//
//  Created by qinwenzhou on 2017/6/15.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

class MaskDrawer: Drawer {
    private var _imageView: UIImageView!
    var maskImageView: UIImageView! {
        return _imageView
    }
    
    override var shape: Shape? {
        didSet {
            if shape is LayerShape {
                let maskLayer = shape as! LayerShape
                maskImageView.layer.mask = maskLayer
            }
        }
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
        _imageView = UIImageView()
        self.addSubview(_imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.frame = self.bounds
    }
}
