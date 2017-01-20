//
//  UIView+Frame.swift
//  special
//
//  Created by 葛枝鑫 on 15/4/24.
//  Copyright (c) 2015年 葛枝鑫. All rights reserved.
//

import Foundation
import UIKit

extension UIView{

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
    
    var yd_ltPoint: CGPoint {
        get {
            return frame.origin
        } set {
            frame = CGRect(origin: newValue, size: frame.size)
        }
    }
    
    var yd_right_offset: CGFloat?  {
        get {
            if let superview = self.superview {
                return superview.yd_width - self.yd_right
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue, let superview = self.superview {
                self.yd_right = superview.yd_width - newValue
            }
        }
    }
    
    var yd_bottom_offset: CGFloat? {
        get {
            if let superview = self.superview {
                return superview.yd_height - self.yd_bottom
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue, let superview = self.superview {
                self.yd_bottom = superview.yd_height - newValue
            }
        }
    }
}
