//
//  UIImage+Extension.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/9/23.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

extension UIImage {
    
    public class func fromColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage!
    }
}
