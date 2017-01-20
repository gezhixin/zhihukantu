//
//  YDBackMenuTableViewCell.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/9/25.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

let YDBackMenuCellOpened = "YDBackMenuCellOpened"
let YDBackMenuCellClosed = "YDBackMenuCellClosed"

open class YDBackMenuTableViewCell: UITableViewCell {
    weak var delegate: YDBackMenuCellDelegate?
    var isCellOpened = false
    var backMenuWidth: CGFloat = 150   //子类重新赋值
    fileprivate var pan: UIPanGestureRecognizer?
   
    var ydContentView: UIView? {
        didSet{
            if let contentV = ydContentView {
                self.pan = UIPanGestureRecognizer(target: self, action: #selector(YDBackMenuTableViewCell.pan(_:)))
                self.pan!.delegate = self
                contentV.addGestureRecognizer(self.pan!)
            }
        }
    }
    
    var _menuEnable: Bool! = true
    var memuEnable: Bool! {
        set {
            _menuEnable = newValue
            if _menuEnable == true {
                if self.pan == nil {
                    self.pan = UIPanGestureRecognizer(target: self, action: #selector(YDBackMenuTableViewCell.pan(_:)))
                    self.pan!.delegate = self
                    self.ydContentView?.addGestureRecognizer(self.pan!)
                }
            } else {
                if let pan = self.pan {
                    self.ydContentView?.removeGestureRecognizer(pan)
                    self.pan?.delegate = nil
                    self.pan = nil
                }
            }
        }
        get {
            return _menuEnable
        }
    }
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    //子类需要实现此方法，实现contentView实际位置操作
    func setMyContentViewX(_ x: CGFloat) {
        
    }
    
    func pan(_ gesture:UIPanGestureRecognizer)
    {
        let point = gesture.translation(in: self)
        
        if (point.x > (0 - self.backMenuWidth) && point.x < (self.frame.size.width - self.backMenuWidth) && isCellOpened == false) {
            self.setMyContentViewX(point.x)
        }
        
        if (point.x > 0  && isCellOpened == true) {
            self.setMyContentViewX(point.x - self.backMenuWidth)
        }
        
        if gesture.state == .ended
        {
            if point.x < -35 {
                self.openMenu()
            } else {
                self.closeMenu()
            }
        }
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let point = gesture.translation(in: self)
            let lPont = gesture.location(in: self)
            
            if (lPont.x < 55 && point.x > 0) {
                return false
            }
            if abs(point.x) - 1 > abs(point.y) {
                return true
            } else {
                return false
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    func closeMenu() {
        self.isCellOpened = false
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.setMyContentViewX(0)
            }, completion: { (finished) -> Void in
                if finished == true {
                    UIView.animate(withDuration: 0.15, animations: { () -> Void in
                        self.setMyContentViewX(-15)
                        }, completion: { (finished) -> Void in
                            if finished == true {
                                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                                })
                                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                                    self.setMyContentViewX(0)
                                    }, completion: { (finished) -> Void in
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: YDBackMenuCellClosed), object: self)
                                        if (nil != self.delegate && self.delegate?.responds(to: #selector(YDBackMenuCellDelegate.backMenuCellMenuClosed(_:))) != false) {
                                            self.delegate!.backMenuCellMenuClosed!(self)
                                        }
                                })
                            }
                    })
                }
        })
    }
    
    func openMenu() {
        self.isCellOpened = true
        
        UIView.animate(withDuration: 0.0, animations: { () -> Void in
            self.setMyContentViewX(-self.backMenuWidth)
            }, completion: { (finished) -> Void in
                if finished == true {
                    if (nil != self.delegate && self.delegate?.responds(to: #selector(YDBackMenuCellDelegate.backMenuCellMenuOpened(_:))) != false) {
                        self.delegate!.backMenuCellMenuOpened!(self)
                    }
                }
        }) 
    }
}

@objc protocol YDBackMenuCellDelegate: NSObjectProtocol {
    @objc optional func backMenuCellMenuOpened(_ cell: YDBackMenuTableViewCell)
    @objc optional func backMenuCellMenuClosed(_ cell: YDBackMenuTableViewCell)
}
