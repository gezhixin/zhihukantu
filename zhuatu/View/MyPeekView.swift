//
//  MyPeekView.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/13.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class MyPeekView: UIVisualEffectView {
    
    static var sharedView: MyPeekView? = nil
    
    lazy var imageEntity: ImageEntity = ImageEntity()
    
    var bklOptionClicked: ((ImageEntity?, UIButton?) -> Void)?

    class func show(with imageEntity: ImageEntity, dismiss:((ImageEntity?, UIButton?) -> Void)?) {
        if sharedView == nil {
            let view = MyPeekView(imageEntity: imageEntity)
            sharedView = view
            view.bklOptionClicked = dismiss
            view.show()
        }
    }
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(imageEntity: ImageEntity ) {
        self.init(effect: nil)
        self.frame = UIScreen.main.bounds
        self.imageEntity = imageEntity
        initUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    
    func show() -> Void {
        let inView = UIApplication.shared.keyWindow!
        inView.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1
            }) { (b) in
                
        }
    }
    
    func dismiss(_ imEntity: ImageEntity?, btn: UIButton?) -> Void {
       MyPeekView.sharedView = nil
        UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0
            }) { (b) in
                self.removeFromSuperview()
                self.bklOptionClicked?(imEntity, btn)
        }
    }
    
    
    func onTap(_ tap: UITapGestureRecognizer) -> Void {
        self.dismiss(nil, btn: nil)
    }
    
    func initUI() {
        
        self.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let vc = ImagePeekPreViewController(imageEntity: imageEntity)
        vc.view.frame = CGRect(x: 10, y: 80, width: self.yd_width - 20, height: 320)
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        vc.view.layer.masksToBounds = true
        vc.view.layer.cornerRadius = 8
        addSubview(vc.view)
        
        var options: [String] = []
        if !imageEntity.questionId.isEmpty && !imageEntity.userId.isEmpty {
            options = ["查看答案", "个人主页", "分享"]
        } else if !imageEntity.userId.isEmpty {
            options = ["个人主页", "分享"]
        } else if !imageEntity.questionId.isEmpty {
            options = ["查看答案", "分享"]
        }else {
            options = ["分享"]
        }
        
        weak var wSelf = self
        let menuView = PopuMenuView(frame: CGRect(x: 10, y: 0, width: self.yd_width - 20, height: 0))
        menuView.backgroundColor = UIColor.white
        menuView.btnHeight = 60
        menuView.options = options
        menuView.layer.masksToBounds = true
        menuView.layer.cornerRadius = 8
        menuView.bklOptionClicked = { (btn) in
            wSelf?.dismiss(wSelf?.imageEntity, btn: btn)
        }
        addSubview(menuView)
        menuView.yd_bottom_offset = 20
        vc.view.yd_bottom = menuView.yd_y - 40
    }
}
