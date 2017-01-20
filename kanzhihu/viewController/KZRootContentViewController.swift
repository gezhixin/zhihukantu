//
//  KZRootContentViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/23.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

let iconNormalColor = UIColor.white
let iconFreshingColor = UIColor(hex: 0x2196f3)
let iconHasNewColor = UIColor.red

class KZRootContentViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Properties
    var refreshBtn: UIButton?
    var usedViewControllers: [KZListViewController] = []
    
    var pan: UIPanGestureRecognizer!
    var tap: UITapGestureRecognizer!
    
    var list: Results<KZPostEntity>!
    var realm: Realm!
    var listTokon: NotificationToken?
    
    lazy var postListNetwork: KZNetwork = KZNetwork()
    
    
    let lock: NSLock = NSLock()
    
    //MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clear
        title = "看精选"
        
        initRealmList()
        
        self.startIndex = list.count >= 2 ? 1 : 0
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPanAction(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapAction(_:)))
        view.addGestureRecognizer(tap)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if list.count == 0 {
            self.getNewPost()
        } else {
            checkNewPost(thenRefresh: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        listTokon?.stop()
    }
    
    //MARK: - UI
    override func setNaviBarItem() {
        if refreshBtn == nil {
            let rBtn = UIButton(type: .system)
            rBtn.tintColor = UIColor.white
            rBtn.setImage(#imageLiteral(resourceName: "icon_fresh"), for: .normal)
            rBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            rBtn.addTarget(self, action: #selector(onRefreshBtnClikced(_:)), for: .touchUpInside)
            refreshBtn = rBtn
        }
        naviBar?.rightItem = refreshBtn
        if refreshBtn?.tintColor == iconFreshingColor {
            refresh(animated: true)
        }
        
        checkNewPost(thenRefresh: false)
    }
    
    func refresh(animated: Bool) -> Void {
        
        guard let refreshBtn = self.refreshBtn else {
            return
        }
        if animated {
            refreshBtn.tintColor = iconFreshingColor
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: M_PI * 2 as Double)
            rotationAnimation.duration = 2
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = 1000000000
            refreshBtn.imageView?.layer.add(rotationAnimation, forKey: "transform.rotation.z")
        } else {
            refreshBtn.tintColor = iconNormalColor
            refreshBtn.imageView?.layer.removeAllAnimations()
        }
    }
    
    
    //MARK: - 数据库
    func initRealmList() -> Void {
        do {
            realm = try Realm()
            list = realm.objects(KZPostEntity.self).sorted(byProperty: "id", ascending: false)
        } catch {}
        
        listTokon = list.addNotificationBlock({ (changes) in
            switch changes {
            case .initial:
                break
            case .update(_, _, _, _):
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        })
    }
    
    //MARK: - Network
    func checkNewPost(thenRefresh: Bool, forced: Bool = false) -> Void {
        if let localNewestPost = list.first {
            
            let lastCheckNewTime = UserDefaults.standard.double(forKey: "last_chech_new_time")
            let nowTime = NSDate().timeIntervalSince1970
            if nowTime - lastCheckNewTime < 60 * 60 && !forced {
                return
            }
            
            UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "last_chech_new_time")
            UserDefaults.standard.synchronize()
            
            weak var weakSelf = self
            postListNetwork.checkNew(with: localNewestPost.publishtime, success: {
                if thenRefresh {
                    weakSelf?.getNewPost()
                } else {
                    weakSelf?.refreshBtn?.tintColor = iconHasNewColor
                }
            })
        } else {
            getNewPost()
        }
    }
    
    func getNewPost() -> Void {
        
        if refreshBtn?.tintColor == iconFreshingColor {
            return
        }
        
        refresh(animated: true)
        weak var weakSelf = self
        
        let time = Int64(NSDate().timeIntervalSince1970)
        
        postListNetwork.getPostList(with: time, success: {
            weakSelf?.refresh(animated: false)
            weakSelf?.startIndex = 0
            }) { (errorCode, errorMsg) in
                weakSelf?.refresh(animated: false)
                _ = ZXTopPromptView.showWarning(tips: errorMsg, isSmall: true, dissmiss: nil)
        }
    }
    
    func loadMore() -> Void {
        
        if refreshBtn?.tintColor == iconFreshingColor {
            return
        }
        
        refresh(animated: true)
        weak var weakSelf = self
        let orListCount = self.list.count
        if let post = list.last {
            postListNetwork.getPostList(with: post.publishtime, success: {
                guard let strongSelf = weakSelf else { return }
                strongSelf.refresh(animated: false)
                if self.startIndex == orListCount - 1 {
                    let index = strongSelf.startIndex
                    strongSelf.startIndex = index
                }
            }) { (errorCode, errorMsg) in
                weakSelf?.refresh(animated: false)
                _ = ZXTopPromptView.showWarning(tips: errorMsg, isSmall: true, dissmiss: nil)
            }
        }
    }
    
    //MARK: - Actions
    func onRefreshBtnClikced(_ sender: UIButton) -> Void {
        getNewPost()
    }
    
    //MAKR: 滑动手势
    var ogRect: CGRect? = nil
    var touchedViewController: UIViewController? = nil
    func onPanAction(_ pan: UIPanGestureRecognizer) -> Void {
        if pan.state == .began {
            if startIndex == 0 || startIndex == list.count - 1 {
                ogRect = view.frame
            } else {
                ogRect = nil
            }
            let v = pan.velocity(in: self.view)
            if v.y < 0 {
                self.startIndex = self.startIndex + 1
            } else if v.y > 0 {
                self.startIndex = self.startIndex - 1
            }
        } else if pan.state == .ended {
            if let ogRect = self.ogRect {
                if view.yd_y < -20 {
                    self.loadMore()
                }
                if view.frame != ogRect {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame = ogRect
                        }, completion: { (b) in
                            
                    })
                }
            }
        } else if pan.state == .changed {
            if let ogRect = self.ogRect {
                let t = pan.translation(in: self.view)
                let a1 = abs(t.y)
                var offset = t.y
                if a1 > 1 {
                    offset = log10(a1) * offset / 10
                }
                if startIndex == 0 {
                    self.view.yd_y = ogRect.origin.y + offset
                } else if startIndex == list.count - 1 {
                    self.view.yd_y = ogRect.origin.y + offset
                }
            }
        }
    }
    
    func onTapAction(_ tap: UITapGestureRecognizer) -> Void {
        var touchedViewController: UIViewController? = nil
        for vc in usedViewControllers {
            let point = tap.location(in: vc.view)
            if point.x > 0 && point.x < vc.view.yd_width && point.y > 0 && point.y < vc.view.yd_height {
                touchedViewController = vc
            }
        }
        
        if let vc = touchedViewController as? KZListViewController {
            popViewController(vc)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pan {
            let v = pan.velocity(in: self.view)
            if abs(v.y) > abs(v.x) {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    //MARK: - Pop VC
    func popViewController(_ vc: KZListViewController) -> Void {
        
        let rootViewController = UIApplication.shared.appDelegate.rootViewController
        
        let orFrame = vc.view.frame
        
        vc.isSmall = false
        
        weak var weakSelf = self
        vc.blkDismiss = {
            (c) in
            guard let strongSelf = weakSelf else {
                return
            }
            guard let index = strongSelf.usedViewControllers.index(of: c) else {
                rootViewController.popViewController(animated: true)
                return
            }
            
            rootViewController.popViewController(animated: false)
            
            c.isSmall = true
            
            if index == strongSelf.usedViewControllers.count - 1 {
                strongSelf.view.addSubview(c.view)
            } else {
                let lastVc = strongSelf.usedViewControllers[index + 1] 
                strongSelf.view.insertSubview(c.view, belowSubview: lastVc.view)    
            }
            
            UIView.animate(withDuration: 0.25, animations: { 
                c.view.frame = orFrame
            })
            
        }
        rootViewController.push(with: vc, animated: true, direction: .none  )
    }
    
    //MARK: - 卡片队列
    private var _startIndex: Int = 0
    var startIndex: Int {
        set {
            if newValue < 0 || newValue >= self.list.count {
                return
            }
            
            
            let offset = newValue - _startIndex
            _startIndex = newValue
           
            
            //往上滑
            
            lock.lock()
            
            
            if offset > 0 {
                if usedViewControllers.count > 2 && _startIndex > 2 {
                    let vc = usedViewControllers.removeFirst()
                    vc.view.yd_y =  vc.view.yd_height + 60
                    self.view.bringSubview(toFront: vc.view)
                    usedViewControllers.append(vc)
                }
            } else if offset < 0 {
                if usedViewControllers.count > 2 && _startIndex > 1 {
                    let vc = usedViewControllers.removeLast()
                    self.view.sendSubview(toBack: vc.view)
                    vc.view.frame = vc.view.bounds
                    usedViewControllers.insert(vc, at: 0)
                    
                }
            }
            updateCards()
            
            lock.unlock()
            
            if _startIndex + 5 > list.count {
                self.loadMore()
            }
        }
        get {
            return _startIndex
        }
    }
    
    //MARK: - 卡片布局
    /*
     * 先更新队列
     * 再更新 UI 位置
     * 最后刷新数据
     *
     */
    
    func layoutCards() -> Void {
        for (index, vc) in usedViewControllers.enumerated() {
            vc.view.frame.size = self.view.bounds.size
            if startIndex == 0 {
                if index == 0 {
                    vc.view.yd_y = 0
                } else if index == 1 {
                    vc.view.yd_y = UIScreen.main.bounds.size.height - 264
                } else if index == 2 {
                    vc.view.yd_y =  vc.view.yd_height + 60
                } else if index == 3 {
                    vc.view.yd_y =  vc.view.yd_height + 60
                } else {
                    vc.view.yd_y =  vc.view.yd_height + 60
                }
            } else if startIndex == 1 {
                if index == 0 {
                    vc.view.yd_y = 0
                } else if index == 1 {
                    vc.view.yd_y = 80
                } else if index == 2 {
                    vc.view.yd_y = UIScreen.main.bounds.size.height - 174
                } else {
                    vc.view.yd_y =  vc.view.yd_height + 60
                }
            } else {
                if index == 0 {
                    vc.view.yd_y = 0
                } else if index == 1 {
                    vc.view.yd_y = 0
                } else if index == 2 {
                    vc.view.yd_y = 80
                } else if index == 3 && startIndex != list.count - 1 {
                    vc.view.yd_y = UIScreen.main.bounds.size.height - 184
                } else if index == 4 {
                    vc.view.yd_y =  vc.view.yd_height + 60
                }
            }
        }
    }
    
    func updateCardsData() -> Void {
        for i in 0 ..< 5 {
            let entityIndex = startIndex < 3 ? i : i + _startIndex - 2
            if entityIndex >= 0 && entityIndex < list.count {
                let post = list[entityIndex]
                if usedViewControllers.count > 0 && i < usedViewControllers.count {
                    let vc = usedViewControllers[i]
                    vc.postEntity = post
                }
            }
        }
    }
    
    func updateCards() -> Void {
        
        for i in 0 ..<  5 {
            
            let entityIndex = startIndex < 3 ? i : i + _startIndex - 2
            
            if entityIndex >= 0 && entityIndex < list.count {
                let post = list[entityIndex]
                if !(usedViewControllers.count > 0 && i < usedViewControllers.count) {
                    let vc = KZListViewController()
                    self.view.addSubview(vc.view)
                    vc.postEntity = post
                    usedViewControllers.append(vc)
                }
            }
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutCards()
        }) { (b) in
            self.updateCardsData()
        }
    }
}
