//
//  CALayer+ZXAdd.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/12/19.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

extension CALayer {
    
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        if let context = UIGraphicsGetCurrentContext() {
            self.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
    

    func setLayerShadow(_ color: UIColor, offset:CGSize, radius: CGFloat) {
        self.shadowColor = color.cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = 1
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
    }
    
    var yd_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newX) {
            var point = self.frame.origin
            point.x = newX
            self.frame = CGRect(origin: point, size: self.frame.size)
        }
    }
   
    var yd_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set(newY) {
            var point = self.frame.origin
            point.y = newY
            self.frame = CGRect(origin: point, size: self.frame.size)
        }
    }
    
    var yd_width: CGFloat {
        get {
            return self.frame.size.width
        }
        set(newWidth) {
            let point = self.frame.origin
            var size = self.frame.size
            size.width = newWidth
            self.frame = CGRect(origin: point, size: size)
        }
    }
   
    var yd_height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newHeight) {
            let point = self.frame.origin
            var size = self.frame.size
            size.height = newHeight
            self.frame = CGRect(origin: point, size: size)
        }
    }
    
    var yd_right: CGFloat {
        get {
            return self.yd_x + self.yd_width
        }
        set {
           self.yd_x = newValue - self.yd_width
        }
    }
    
    var yd_bottom: CGFloat {
        get {
            return self.yd_y + self.yd_height
        }
        set {
            self.yd_y = newValue - self.yd_height
        }
    }
    
    var transformScale: NSNumber {
        get {
            return self.value(forKeyPath: "transform.scale") as! NSNumber
        }
        set {
            self.setValue(newValue, forKeyPath: "transform.scale")
        }
    }
}
