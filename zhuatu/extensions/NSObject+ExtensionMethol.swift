//
//  NSObject+ExtensionMethol.swift
//  yuandingzhushou
//
//  Created by 葛枝鑫 on 15/9/19.
//  Copyright (c) 2015年 葛枝鑫. All rights reserved.
//

import UIKit

extension  NSObject {
    class var yd_className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
