//
//  UIButton+Block.swift
//  yuandingzhushou
//
//  Created by 葛枝鑫 on 15/9/19.
//  Copyright (c) 2015年 葛枝鑫. All rights reserved.
//

import UIKit

typealias BlkBtnEvent =  (_ index: Int, _ btn: UIButton) -> Void

private var blkTouchUpInsideKey: Int = 0

extension UIButton {
    
    convenience init(touchUpInsideBlk: BlkBtnEvent?) {
        self.init()
        self.blkTouchUpInside = touchUpInsideBlk
    }

    var blkTouchUpInside: BlkBtnEvent? {
        get {
            let eblk = objc_getAssociatedObject(self, &blkTouchUpInsideKey) as! ExBlock
            return eblk.blk as? BlkBtnEvent
        }
        set(newValue) {
            objc_setAssociatedObject(self, &blkTouchUpInsideKey, ExBlock(blk: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            self.removeTarget(self, action: #selector(UIButton.onTouchUpInside), for: UIControlEvents.touchUpInside)
            if (newValue != nil) {
                self.addTarget(self, action: #selector(UIButton.onTouchUpInside), for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    @objc  fileprivate func onTouchUpInside() {
        if let blk = self.blkTouchUpInside {
            blk(self.tag, self)
        }
    }
}

class ExBlock {
    var blk: Any?
    
    init(blk: Any?) {
        self.blk = blk
    }
}
