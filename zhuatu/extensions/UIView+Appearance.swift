//
//  UIView+Appearance.swift
//  special
//
//  Created by 葛枝鑫 on 15/4/22.
//  Copyright (c) 2015年 葛枝鑫. All rights reserved.
//
/**
*
*/



import UIKit
import Foundation

extension UIView {
    func setBorder(_ color: UIColor, width:CGFloat)
    {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func setCornerRadius(_ cornerRadius:CGFloat, bMaskToBounds: Bool = true)
    {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = bMaskToBounds
    }
}
