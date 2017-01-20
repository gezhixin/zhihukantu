//
//  UIView+IBundle.swift
//  yuandingzhushou
//
//  Created by 葛枝鑫 on 15/9/19.
//  Copyright (c) 2015年 葛枝鑫. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNib() -> UIView {
        return Bundle.main.loadNibNamed(self.yd_className, owner: nil, options: nil)!.first as! UIView
    }
}
