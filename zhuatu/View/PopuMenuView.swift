//
//  PopuMenuView.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/13.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class PopuMenuView: UIVisualEffectView {
    
    fileprivate var btns: [UIButton] = []
    fileprivate var lines: [UIView] = []
    
    var btnHeight: CGFloat = 40
    
    fileprivate var _optionColor: UIColor = UIColor(hex: 0x202020)
    var optionColor: UIColor {
        set {
            _optionColor = newValue
            for btn in btns {
                btn.setTitleColor(newValue, for: UIControlState())
            }
        } get {
            return _optionColor
        }
    }
    
    fileprivate var _options: [String]!
    var options: [String] {
        set {
            _options = newValue
            self.initUIWithOptions(newValue)
        } get {
            return _options
        }
    }
    
    var bklOptionClicked: ((UIButton) -> Void)?

    override init(effect: UIVisualEffect?) {
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(options: [String]) {
        self.init(effect: nil)
        
    }
    
    
    
    func initUIWithOptions(_ options: [String]) {
        
        for btn in btns {
            btn.removeFromSuperview()
        }
        for line in lines {
            line.removeFromSuperview()
        }
        
        for i in 0 ..< options.count {
            let title = options[i]
            weak var weakSelf = self
            let btn = UIButton(touchUpInsideBlk: { (index, btn) in
                weakSelf?.bklOptionClicked?(btn)
            })
            btns.append(btn)
            btn.tag = i
            btn.frame = CGRect(x: 0, y: btnHeight * CGFloat(i), width: self.yd_width, height: btnHeight)
            btn.setTitleColor(_optionColor, for: UIControlState())
            btn.setTitleColor(_optionColor.withAlphaComponent(0.5), for: .highlighted)
            btn.setTitle(title, for: UIControlState())
            btn.backgroundColor = UIColor.clear
            contentView.addSubview(btn)
            
            if i != options.count - 1 {
                let line = UIView(frame: CGRect(x: 5, y: btnHeight * CGFloat(i + 1), width: self.yd_width - 10, height: 0.5))
                line.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                lines.append(line)
                contentView.addSubview(line)
            }
        }
        
        self.yd_height = btns.last != nil ? btns.last!.yd_bottom : 0
    }
}
