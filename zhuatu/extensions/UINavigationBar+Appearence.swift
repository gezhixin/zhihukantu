//
//  UINavigationBar+Appearance.swift
//  ydzs
//
//  Created by 葛枝鑫 on 16/1/29.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

private var ydOverlayKey: Int = 0

extension UINavigationBar {
    
    var yd_overlay: UIView? {
        get {
            return objc_getAssociatedObject(self, &ydOverlayKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &ydOverlayKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func yd_setBackgroundColor(_ color: UIColor) {
        if nil == self.yd_overlay {
            self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.yd_overlay = UIView(frame: CGRect(x: 0, y: -20, width: UIScreen.main.bounds.size.width, height: self.bounds.height + 20))
            self.yd_overlay?.isUserInteractionEnabled = false
            self.yd_overlay?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.insertSubview(self.yd_overlay!, at: 0)
        }
        self.yd_overlay?.backgroundColor = color
    }
    
    func yd_setTranslationY(_ translationY: CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    func yd_setElementsAlpha(_ alpha: CGFloat) {
        if let leftViews = self.value(forKey: "_leftViews") as? [UIView] {
            for view in leftViews {
                view.alpha = alpha
            }
        }
        
        if let _rightViews = self.value(forKey: "_rightViews") as? [UIView] {
            for view in _rightViews {
                view.alpha = alpha
            }
        }
        
        if let titleView = self .value(forKey: "_titleView") as? UIView {
            titleView.alpha = alpha
        }
        
        for view in self.subviews {
            if view.isKind(of: NSClassFromString("UINavigationItemView")!) {
                view.alpha = alpha
                break
            }
        }
    }
    
    func yd_reset() {
        self.setBackgroundImage(nil, for: .default)
        self.yd_overlay?.removeFromSuperview()
        self.yd_overlay = nil
    }
    
}
