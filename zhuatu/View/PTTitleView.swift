//
//  PTTitleView.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/23.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class PTTitleView: UIVisualEffectView {
    
    fileprivate var _leftItem: UIView?
    fileprivate var _rightItem: UIView?
    
    var titleLabel: UILabel!
    
    var title: String? {
        set {
            titleLabel.text = newValue
        } get {
            return titleLabel.text
        }
    }
    
    var leftItem: UIView? {
        set {
            if newValue == _leftItem {
                return
            }
            
            _leftItem?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
                newValue.frame = CGRect(origin: CGPoint(x: 0, y: yd_height - newValue.yd_height), size: newValue.frame.size)
            }
            
            _leftItem = newValue
        } get {
            return _leftItem
        }
    }
    
    var rightItem: UIView? {
        set {
            if newValue == _rightItem {
                return
            }
            
            _rightItem?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
                newValue.frame = CGRect(origin: CGPoint(x: yd_width - newValue.yd_width, y: yd_height - newValue.yd_height), size: newValue.frame.size)
            }
            
            _rightItem = newValue
        } get {
            return _rightItem
        }
    }
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with title: String?) {
        self.init(effect: nil)
        
        self.backgroundColor = UIColor(hex: 0, alpha: 0.3)
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.text = title
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 60, y: 0, width: self.yd_width - 120, height: self.yd_height)
        
        if let r = _rightItem {
            r.frame = CGRect(origin: CGPoint(x: yd_width - r.yd_width, y: yd_height - r.yd_height), size: r.frame.size)
        }
        
        if let l = _leftItem {
            l.frame = CGRect(origin: CGPoint(x: 0, y: yd_height - l.yd_height), size: l.frame.size)
        }
    }
}
