//
//  CreateOnePatuBox.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class CreateOnePatuBox: UIView {

    var dismissBlk: ((_ isCreate: Bool,_ text: String?) -> Void)?
    
    var contentView: UIVisualEffectView!
    var textfield: UITextField!
    var startBtn: UIButton!
    
    var placeHolder: String? {
        set {
            textfield.placeholder = newValue
        } get {
            return textfield.placeholder
        }
    }
    
    var buttonTitle: String? {
        set {
            startBtn.setTitle(newValue, for: .normal)
        } get {
            return startBtn.titleLabel?.text
        }
    }
    
    fileprivate var _emptyWarningText: String = "ID都没填！\n我是搞不了的😌"
    var emptyWarningText: String {
        set {
            _emptyWarningText = newValue
        } get {
            return _emptyWarningText
        }
    }
    
    convenience init(dismiss: ((_ isCreate: Bool,_ text: String?) -> Void)?) {
        self.init(frame: UIScreen.main.bounds)
        self.dismissBlk = dismiss
        let sw = UIScreen.main.bounds.size.width
        let sh = UIScreen.main.bounds.size.height
        contentView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        contentView.frame = CGRect(x: 30, y: (sh - 110) / 2, width: sw - 60, height: 110)
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 3
        addSubview(contentView)
        
        textfield = UITextField(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 40))
        textfield.font = UIFont.systemFont(ofSize: 15)
        textfield.placeholder = "问题ID"
        textfield.textAlignment = .center
        textfield.keyboardType = .numberPad
        contentView.addSubview(textfield)
        
        let brect = CGRect(x: -2, y: 69, width: contentView.frame.size.width + 4, height: 42)
        startBtn = UIButton(frame: brect)
        startBtn.layer.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
        startBtn.layer.borderWidth = 0.5
        startBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: UIControlState())
        startBtn.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        startBtn.setTitle("看    图", for: UIControlState())
        startBtn.addTarget(self, action: #selector(self.onCreateBtnClicked(_:)), for: .touchUpInside)
        contentView.addSubview(startBtn)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onBbTap(_:)))
        self.addGestureRecognizer(tap)
        
        contentView.yd_bottom = -1
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateOnePatuBox.keyboardDidShow(_:)), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateOnePatuBox.keyboardDidHide(_:)), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func show() {
        let inView = UIApplication.shared.keyWindow!
        if self.superview != nil {
            self.removeFromSuperview()
        }
        
        inView.addSubview(self)
        
        self.textfield.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.backgroundColor = UIColor(hex: 0x0, alpha: 0.3)
            self.contentView.center.y = UIScreen.main.bounds.size.height / 2
        }) 
    }
    
    func dismiss(_ isCreate: Bool) -> Void {
        UIView.animate(withDuration: 0.3, animations: { 
            self.contentView.yd_bottom = -1
            }, completion: { (b) in
                self.removeFromSuperview()
                self.dismissBlk?(isCreate, self.textfield.text)
        }) 
    }
    
    func onBbTap(_ tap: UITapGestureRecognizer) -> Void {
        self.dismiss(false)
    }
    
    func onCreateBtnClicked(_ sender: UIButton) -> Void {
        if textfield.text != nil && textfield.text!.characters.count > 0 {
            self.dismiss(true)
        } else {
            _ = ZXTopPromptView.showWarning(tips: emptyWarningText)
        }
    }
    
    /// 监听键盘弹出
    func keyboardDidShow(_ notification: Notification) {
        
        let info  = (notification as NSNotification).userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = self.convert(rawFrame!, from: nil)
        
        if contentView.yd_bottom > keyboardFrame.origin.y - 10 {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.contentView.yd_bottom = keyboardFrame.origin.y - 10
            }) 
        }
        
    }
    
    /// 监听键盘收回
    func keyboardDidHide(_ notification: Notification) {
    }
}
