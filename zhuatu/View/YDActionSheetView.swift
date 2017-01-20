//
//  YDActionSheetView.swift
//  ydzs
//
//  Created by 葛枝鑫 on 16/1/5.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

class YDActionSheetView: UIView {

    static let CancleBtnTag: Int = 987654678
    static let DestructiveBtnTag: Int = 83694856
    
    var btnContentView: UIView!
    
    var title: String?
    var cancleBtnTitle: String?
    var destructiveBtnTitle: String?
    var otherBtnTitles: [String?]?
    
    var blkAction: ((_ index: Int) -> Void)?
    
    convenience init(title: String?, cancleButton: String?, destructiveButton: String?, otherButtons: String?..., buttonIndex: ((_ index: Int) -> Void)?) {
        self.init(frame: UIScreen.main.bounds)
        self.title = title
        self.cancleBtnTitle = cancleButton
        self.destructiveBtnTitle = destructiveButton
        self.otherBtnTitles = otherButtons
        self.blkAction = buttonIndex
        self.initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - UI
    fileprivate func initUI() {
        self.backgroundColor = UIColor.clear
        
        self.btnContentView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
        var titleLabel: UILabel? = nil
        if let title = self.title {
            titleLabel = UILabel()
            titleLabel?.font = UIFont.systemFont(ofSize: 13)
            titleLabel?.textColor = UIColor(hex: 0x666666)
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.textAlignment = .center
            titleLabel?.numberOfLines = 0
            titleLabel?.text = title
            titleLabel?.frame.size = (titleLabel?.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width - 30, height: CGFloat.greatestFiniteMagnitude)))!
            titleLabel?.yd_x = 15
            titleLabel?.yd_y = 0
            titleLabel?.yd_width = UIScreen.main.bounds.size.width - 30
            if let height = titleLabel?.yd_height {
                titleLabel?.yd_height = height < 50 ? 50 : height + 30
            }
            self.btnContentView.addSubview(titleLabel!)
            
            let line = self.createLine()
            line.yd_y = titleLabel!.yd_bottom
            self.btnContentView.addSubview(line)
        }
        
        var lastOtherBtn: UIButton? = nil
        if let otherBtnTitles = self.otherBtnTitles {
            for i in 0 ..< otherBtnTitles.count {
                guard let otherBtnTitle = otherBtnTitles[i] else {
                    continue
                }
                let btn = self.createBtn(otherBtnTitle)
                btn.tag = i
                self.btnContentView.addSubview(btn)
                if lastOtherBtn == nil {
                    if let titleLabel = titleLabel {
                        btn.yd_y = titleLabel.yd_bottom + 0.5
                    } else {
                        btn.yd_y = 0
                    }
                } else {
                    btn.yd_y = lastOtherBtn!.yd_bottom + 0.5
                }
                lastOtherBtn = btn
                
                let line = self.createLine()
                line.yd_y = btn.yd_bottom
                self.btnContentView.addSubview(line)
            }
        }
        
        var destructiveBtn: UIButton? = nil
        if let destructiveBtnTitle = self.destructiveBtnTitle {
            destructiveBtn = self.createBtn(destructiveBtnTitle)
            destructiveBtn?.setTitleColor(UIColor.red, for: UIControlState())
            destructiveBtn?.tag = YDActionSheetView.DestructiveBtnTag
            if let lastOtherBtn = lastOtherBtn {
                destructiveBtn?.yd_y = lastOtherBtn.yd_bottom + 0.5
            } else if let titleLabel = titleLabel {
                destructiveBtn?.yd_y = titleLabel.yd_bottom + 0.5
            }else {
                destructiveBtn?.yd_y = 0
            }
            self.btnContentView.addSubview(destructiveBtn!)
        }
        
        var cancleBtn: UIButton? = nil
        if let cancleBtnTitle = self.cancleBtnTitle {
            let line = self.createLine()
            line.backgroundColor = UIColor(hex: 0xeeeeee)
            line.yd_height = 10
            if let destructiveBtn = destructiveBtn {
                line.yd_y = destructiveBtn.yd_bottom
            } else if let lastOtherBtn = lastOtherBtn {
                line.yd_y = lastOtherBtn.yd_bottom
            }
            self.btnContentView.addSubview(line)
            
            cancleBtn = self.createBtn(cancleBtnTitle)
            cancleBtn?.tag = YDActionSheetView.CancleBtnTag
            cancleBtn?.yd_height = 50
            cancleBtn?.yd_y = line.yd_bottom
            self.btnContentView.addSubview(cancleBtn!)
        }
        
        if let cancleBtn = cancleBtn {
            self.btnContentView.yd_height = cancleBtn.yd_bottom
        } else if let destructiveBtn = destructiveBtn {
            self.btnContentView.yd_height = destructiveBtn.yd_bottom
        } else if let lastOtherBtn = lastOtherBtn {
            self.btnContentView.yd_height = lastOtherBtn.yd_bottom
        } else if let titleLabel = titleLabel {
            self.btnContentView.yd_height = titleLabel.yd_bottom
        }
        self.btnContentView.yd_width = UIScreen.main.bounds.size.width
        self.btnContentView.yd_y = self.yd_bottom
        self.btnContentView.backgroundColor = UIColor.white
        self.addSubview(self.btnContentView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(YDActionSheetView.tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func show() {
        
        let inView = UIApplication.shared.keyWindow!
        if self.superview != nil {
            self.removeFromSuperview()
        }
        
        inView.addSubview(self)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.backgroundColor = UIColor(hex: 0x0, alpha: 0.3)
            self.btnContentView.yd_bottom = self.yd_bottom
        }) 
    }
    
    fileprivate func createBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(YDActionSheetView.menuBtnClicked(_:)), for: .touchUpInside)
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        btn.setBackgroundImage(UIImage.fromColor(UIColor.white), for: UIControlState())
        btn.setBackgroundImage(UIImage.fromColor(UIColor(hex: 0xf6f6f6)), for: .highlighted)
        btn.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40)
        return btn
    }
    
    fileprivate func createLine() -> UIView {   
        let line = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.5))
        line.backgroundColor = UIColor(hex: 0xeeeeee)
        return line
    }
    
    //MARK: - Actions
    func tapAction(_ tapGesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.btnContentView.yd_y = self.yd_bottom
            self.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                if finished {
                    self.removeFromSuperview()
                }
        }) 
    }
    
    func menuBtnClicked(_ btn: UIButton) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.btnContentView.yd_y = self.yd_bottom
            self.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                if finished {
                    self.removeFromSuperview()
                    self.blkAction?(btn.tag)
                }
        }) 
    }
}
