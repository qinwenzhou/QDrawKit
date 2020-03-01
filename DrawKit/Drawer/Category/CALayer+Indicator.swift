//
//  DrawView+Indicator.swift
//  DrawKit
//
//  Created by zte on 2016/9/14.
//  Copyright © 2016年 qwz. All rights reserved.
//

import UIKit

class Indicator: CAShapeLayer {
    override var bounds: CGRect {
        didSet {
            _drawIndicator()
        }
    }
    
    private func _drawIndicator() {
        self.path = UIBezierPath(ovalIn: bounds).cgPath
        self.fillColor = UIColor.color(R: 0, G: 122, B: 255).cgColor
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 4
        
        self.shadowColor = UIColor.black.cgColor
        self.shadowOffset = CGSize(width: 0.1, height: 0.1)
        self.shadowOpacity = 0.8
        self.shadowRadius = 1.0
    }
}

extension CALayer {
    func showIndicators(at positions: [CGPoint]) {
        removeAllIndicators()
        
        for p in positions {
            let indicator = Indicator()
            indicator.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            self.addSublayer(indicator)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            indicator.position = p
            CATransaction.commit()
        }
    }
    
    func removeAllIndicators() {
        if let layers = self.sublayers {
            for l in layers {
                if l is Indicator {
                    l.removeFromSuperlayer()
                }
            }
        }
    }
}
