//
//  Brush.swift
//  Drawing
//
//  Created by zte on 2017/5/31.
//  Copyright © 2017年 qwz. All rights reserved.
//

import UIKit

public enum ArrowType {
    case cone // 锥形箭头（头大尾小）
    case line // 线形箭头（头尾大小一致）
}

public enum LineType {
    case track // 轨迹
    case straight // 直线
}

public enum RectType {
    case oval // 椭圆
    case rect // 矩形
    case roundRect // 圆角矩形
}

public enum TextType {
    case text
    case borderText // 带边框的文本
}


// MARK: - Brush

public protocol Brush {
    var tag: Int {set get} // 唯一标识
}


public struct ArrowBrush: Brush {
    public var tag: Int = 0
    
    private var _type: ArrowType
    public var type: ArrowType {
        return _type
    }
    
    public var arrowColor: UIColor?
    public var arrowSize: CGFloat = 15
    public var hookFactor: CGFloat = 0.2 // 这个值越大，锥形箭头显得越尖。取值范围：(0 ~ 1)。此属性对线性箭头无效
    
    
    public init(type: ArrowType) {
        _type = type
    }
}


public struct LineBrush: Brush {
    public var tag: Int = 0

    private var _type: LineType
    public var type: LineType {
        return _type
    }
    
    public var lineColor: UIColor?
    public var lineWidth: CGFloat = 5
    
    
    public init(type: LineType) {
        _type = type
    }
}


public struct RectBrush: Brush {
    public var tag: Int = 0
    
    private var _type: RectType
    public var type: RectType {
        return _type
    }
    
    public var lineColor: UIColor?
    public var lineWidth: CGFloat = 5
    
    
    public init(type: RectType) {
        _type = type
    }
}


public struct SolidBrush: Brush {
    public var tag: Int = 0
    
    private var _type: RectType
    public var type: RectType {
        return _type
    }
    
    public var solidColor: UIColor?
    
    
    public init(type: RectType) {
        _type = type
    }
}


public struct MaskBrush: Brush {
    public var tag: Int = 0
    
    private var _type: RectType
    public var type: RectType {
        return _type
    }
    
    
    public init(type: RectType) {
        _type = type
    }
}


public struct MosaicBrush: Brush {
    public var tag: Int = 0
    
    public init() {
        
    }
}


public struct MagnifierBrush: Brush {
    public var tag: Int = 0
    
    public var magnification: Float = 1.0
    
    
    public init() {
        
    }
}


public struct TextBrush: Brush {
    public var tag: Int = 0
    
    private var _type: TextType
    public var type: TextType {
        return _type
    }
    
    public var textColor: UIColor?
    public var font: UIFont?
    
    
    public init(type: TextType) {
        _type = type
    }
}
