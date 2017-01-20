//
//  UIApplication+extension.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/23.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

extension UIApplication {
    var appDelegate: AppDelegate {
        return self.delegate as! AppDelegate
    }
}
