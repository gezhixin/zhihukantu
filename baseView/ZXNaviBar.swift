//
//  ZXNaviBar.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/22.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class ZXNaviBar: UIView {
    lazy var titleBtns: [UIButton] = []
    
    var titleBtnContentView: UIScrollView!
    
    fileprivate var _viewControllers:[UIViewController] = []
    fileprivate var _leftItem: UIView?
    fileprivate var _rightItem: UIView?
    
    var titleColor: UIColor = UIColor.white
    
    var blkBarItemClicked:((_ index: Int) -> Void)?
    
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
    
    var viewControllers:[UIViewController] {
        set {
            for btn in titleBtns {
                btn.removeFromSuperview()
            }
            _viewControllers = newValue
            for (index, controller) in _viewControllers.enumerated() {
                let btn = UIButton(type: .custom)
                btn.setTitleColor(titleColor, for: .normal)
                btn.tag = index
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                let title = controller.title == nil ? "????" : controller.title!
                btn.setTitle(title, for: .normal)
                btn.addTarget(self, action: #selector(self.onBtnClicked(_:)), for: .touchUpInside)
                let btnW = title.sizeWith(btn.titleLabel!.font, width: 10000).width
                if let lastBtn = titleBtns.last {
                    btn.frame = CGRect(x: lastBtn.yd_right + 5, y: 0, width: btnW, height: 40)
                } else {
                    btn.frame = CGRect(x: (titleBtnContentView.yd_width - btnW) / 2, y: 0, width: btnW, height: 40)
                }
                
                titleBtnContentView.addSubview(btn)
                titleBtns.append(btn)
            }
            self.layoutBtns()
        } get {
            return _viewControllers
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        titleBtnContentView = UIScrollView(frame: CGRect(x: 80, y: 24, width: self.yd_width - 160, height: 40))
        titleBtnContentView.showsVerticalScrollIndicator = false
        titleBtnContentView.showsHorizontalScrollIndicator = false
        titleBtnContentView.bounces = false
        titleBtnContentView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        addSubview(titleBtnContentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        titleBtnContentView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            self.layoutBtns()
        }
    }
    
    func layoutBtns() {
        let xxwidth = titleBtnContentView.yd_width * 3 / 4
        let a = 0 - 1 / (xxwidth * xxwidth)
        for btn in titleBtns {
            var offsetScale = CGFloat(1) + a * (titleBtnContentView.contentOffset.x + titleBtnContentView.yd_width / 2 - btn.center.x) * (titleBtnContentView.contentOffset.x + titleBtnContentView.yd_width / 2 - btn.center.x)
            offsetScale = max(0, offsetScale)
            let btnRect = btn.frame
            btn.frame = CGRect(x: btnRect.origin.x, y: 40 * (1 - offsetScale) , width: btnRect.size.width, height: (40 * offsetScale))
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16 * offsetScale)
            btn.alpha = offsetScale * offsetScale * offsetScale
        }
    }
    
    func onBtnClicked(_ sender: UIButton) -> Void {
        self.blkBarItemClicked?(sender.tag)
    }
}
