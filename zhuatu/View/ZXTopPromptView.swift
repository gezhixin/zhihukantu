//
//  ZXTopPromptView.swift
//  ydzs
//
//  Created by gezhixin on 16/4/26.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

enum ZXTopPromptViewEventType {
    case cancel
    case backgroudTap
}

class ZXTopPromptView: UIVisualEffectView {
    
    static var sharedToppromptView: ZXTopPromptView? = nil
    
    var dissmissBlk: ((_ event: ZXTopPromptViewEventType) -> Void)?
    var duration: TimeInterval = 0
    var myAlertWindow: UIWindow?
    var timer: Timer?
    
    
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    }
    
    
    deinit {
    }
    
    convenience init(duration: TimeInterval, dissmiss:((_ event: ZXTopPromptViewEventType) -> Void)?) {
        self.init(effect: nil)
        self.frame = CGRect(x: 0, y: -30, width: UIScreen.main.bounds.size.width, height: 30)
        self.dissmissBlk = dissmiss
        self.duration = duration
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapAction(_:)))
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPanAction(_:)))
        addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Actions
    func onTimerEnd(_ timer: Timer) -> Void {
        UIView.animate(withDuration: 0.35, animations: { 
            self.yd_y = 0 - self.yd_height
            }, completion: { (finished) in
                self.dissmissBlk?(.cancel)
                self.dissmiss()
        }) 
    }
    
    func onPanAction(_ swip: UIPanGestureRecognizer) -> Void {
    
        let point = swip.velocity(in: self)
        if swip.state == .began {
            if point.y < -1 {
                UIView.animate(withDuration: 0.35, animations: {
                    self.yd_y = 0 - self.yd_height
                    }, completion: { (finished) in
                        self.dissmissBlk?(.cancel)
                        self.dissmiss()
                }) 
            }
        }
    }
    
    func onTapAction(_ tap: UITapGestureRecognizer) -> Void {
        UIView.animate(withDuration: 0.35, animations: {
            self.yd_y = 0 - self.yd_height
            }, completion: { (finished) in
                self.dissmissBlk?(.backgroudTap)
                self.dissmiss()
        }) 
    }
    
    //MARK: - UI
    
    func initView(_ tips: String, btnTitle: String? = nil) -> Void {
        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.textAlignment = .center
        tipsLabel.text = tips
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        let screenWith = UIScreen.main.bounds.size.width
        let size = tips.sizeWith(UIFont.systemFont(ofSize: 14), width: screenWith - 30)
        let tipsHeight = max(40, size.height)
        tipsLabel.frame = CGRect(x: 15, y: 10, width: screenWith - 30, height: tipsHeight)
        contentView.addSubview(tipsLabel)
        
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0, alpha: 0.5)
        view.setCornerRadius(1)
        view.frame = CGRect(x: (screenWith - 30) / 2, y: 64 - 5, width: 30, height: 3)
        contentView.addSubview(view)
       
        contentView.backgroundColor = UIColor(hex: 0xff9900, alpha: 0.95)
        frame = CGRect(x: 0, y: 0, width: screenWith, height: 64)
        yd_y = 0 - yd_height
    }
    
    func initSmallView(_ tips: String) -> Void {
        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.textAlignment = .center
        tipsLabel.text = tips
        tipsLabel.font = UIFont.systemFont(ofSize: 10)
        let screenWith = UIScreen.main.bounds.size.width
        let tipsHeight = CGFloat(24)
        tipsLabel.frame = CGRect(x: 15, y: 0, width: screenWith - 30, height: tipsHeight)
        contentView.addSubview(tipsLabel)
        
        contentView.backgroundColor = UIColor(hex: 0xff9900, alpha: 0.95)
        frame = CGRect(x: 0, y: 0, width: screenWith, height: tipsHeight)
        yd_y = 0 - yd_height
    }
    
    func dissmiss() {
        self.myAlertWindow?.removeFromSuperview()
        self.myAlertWindow = nil
        self.timer = nil
    }
    
    func show() {
        if self.superview != nil {
            self.removeFromSuperview()
        }
        
        let window = UIWindow(frame: CGRect(origin: CGPoint.zero, size: self.frame.size))
        window.windowLevel = UIWindowLevelAlert
        window.makeKeyAndVisible()
        window.addSubview(self)
        myAlertWindow = window
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.window?.makeKey()
        }
        
        UIView.animate(withDuration: 0.35, animations: { () -> Void in
            self.yd_y = 0
        }) 
        
        timer?.invalidate()
        timer = nil
        if duration > 0 {
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.onTimerEnd(_:)), userInfo: nil, repeats: false)
        }
    }
    
    class func showWarning(_ duration: TimeInterval = 4, tips: String?, isSmall: Bool = false, dissmiss: ((_ event: ZXTopPromptViewEventType) -> Void)? = nil) -> ZXTopPromptView? {
        if let tips = tips {
            sharedToppromptView?.removeFromSuperview()
            let view = ZXTopPromptView(duration: duration, dissmiss: dissmiss)
            if isSmall {
                view.initSmallView(tips)
            } else {
                view.initView(tips)
            }
            view.show()
            sharedToppromptView = view
            return view
        }
        
        return nil
    }
    
    class func showSuccess(_ duration: TimeInterval = 4, tips: String?, isSmall: Bool = false, dissmiss: ((_ event: ZXTopPromptViewEventType) -> Void)? = nil) -> ZXTopPromptView? {
        if let tips = tips {
            sharedToppromptView?.removeFromSuperview()
            let view = ZXTopPromptView(duration: duration, dissmiss: dissmiss)
            if isSmall {
                view.initSmallView(tips)
            } else {
                view.initView(tips)
            }
            view.contentView.backgroundColor = UIColor(hex: 0x009ACD)
            view.show()
            sharedToppromptView = view
            return view
        }
        
        return nil
    }
    
    
    
    class func show(_ tips: String, btnTitle: String, dissmiss: ((_ index: ZXTopPromptViewEventType) -> Void)?) {
        let view = ZXTopPromptView(duration: 0, dissmiss: dissmiss)
        view.initView(tips, btnTitle: btnTitle)
        view.show()
    }
}
