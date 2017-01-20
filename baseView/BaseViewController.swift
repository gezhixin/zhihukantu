//
//  BaseViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/23.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    fileprivate var _naviBar: ZXNaviBar?
    var naviBar: ZXNaviBar? {
        set {
            _naviBar = newValue
        } get {
            return _naviBar
        }
    }
    
    var nvc: RootViewController?
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setNaviBarItem() -> Void {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
