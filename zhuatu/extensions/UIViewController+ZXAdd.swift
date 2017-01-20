//
//  UIViewController+ZXAdd.swift
//  ydzs
//
//  Created by gezhixin on 15/12/7.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class func controllerWithDefualtXib() -> UIViewController? {
        return self.init(nibName: self.yd_className, bundle: nil)
    }
}
