//
//  ViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/9.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: BaseViewController, UIGestureRecognizerDelegate  {
    
    //MAKR: - Properties
    var realm: Realm!
    var list: Results<PatuEntity>!
    var listTokon: NotificationToken?
    
    var usedViewControllers: [PTImageListViewController] = []
    
    var pan: UIPanGestureRecognizer!
    var tap: UITapGestureRecognizer!
    
    var backgroundTitleLabel: UILabel!
    
    var isCollections: Bool = false
    
    convenience init(isCollections: Bool = false) {
        self.init()
        self.isCollections = isCollections
    }
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clear
        if isCollections {
            title = "收藏"
            backgroundTitleLabel = UILabel()
            backgroundTitleLabel.textAlignment = .center
            backgroundTitleLabel.textColor = UIColor(hex: 0x666666)
            backgroundTitleLabel.font = UIFont.systemFont(ofSize: 14)
            backgroundTitleLabel.text = "空空无一物"
            self.view.addSubview(backgroundTitleLabel)
            backgroundTitleLabel.frame = CGRect(x: 0, y: self.view.yd_height / 2 - 90, width: self.view.yd_width, height: 40)
        } else {
            title = "B乎"
        }
        
        realm  = try! Realm()
        list = realm.objects(PatuEntity.self).filter("isCollections = %d", isCollections).sorted(byProperty: "createDate", ascending: false)
        
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
        
        self.startIndex = list.count >= 2 ? 1 : 0
                
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPanAction(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapAction(_:)))
        view.addGestureRecognizer(tap)
        
        if !isCollections {
            createGuidImages()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.listTokon?.stop()
    }
    
    override func setNaviBarItem() {
        if isCollections {
            naviBar?.rightItem = nil
            self.startIndex = _startIndex
        } else {
            let rBtn = UIButton(type: .system)
            rBtn.tintColor = UIColor.white
            rBtn.setImage(#imageLiteral(resourceName: "icon_add"), for: .normal)
            rBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            rBtn.addTarget(self, action: #selector((_:onAddItemBtnClicked)), for: .touchUpInside)
            
            naviBar?.rightItem = rBtn
        }
    }

    //MARK: - Actions
    func onAboutBtnClicked(_ item: UIBarButtonItem) -> Void {
        let vc = AboutViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onAddItemBtnClicked(_ item: UIBarButtonItem) -> Void {
        CreateOnePatuBox { (isCreate, text) in
            if isCreate && text != nil {
                self.addQuestionOrOthrer(with: text!)
            }
        }.show()
    }
    
    func addQuestionOrOthrer(with qid: String, url: String? = nil) -> Void {
        let vc = PTImageListViewController(qid: qid, url: url)
        vc.blkDismiss = {
            (c) in
            UIView.animate(withDuration: 0.25, animations: { 
                c.view.alpha = 0
                }, completion: { (b) in
                    c.viewDidDisappear(false)
                    if let patu = c.patuEntity {
                        if let index = self.list.index(of: patu) {
                            self.startIndex = index
                        }
                    }
                    self.updateCards()
                    UIApplication.shared.appDelegate.rootViewController.popViewController(animated: false)
            })
        }
        UIApplication.shared.appDelegate.rootViewController.push(with: vc, direction: .bottom)
    }
    
    func createGuidImages() -> Void {
        if list.count == 0 {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                let guidPatu = PatuEntity()
                guidPatu.title = "【使用指南】"
                guidPatu.questionId = "【使用指南】".md5()
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(guidPatu)
                        for i in 0 ..< 2 {
                            let imageEntity = ImageEntity()
                            imageEntity.name = "about_\(i + 1).PNG"
                            imageEntity.questionId = guidPatu.questionId
                            guidPatu.imageList.append(imageEntity)
                            if let image = UIImage(named: imageEntity.name) {
                                if let data = UIImageJPEGRepresentation(image, 1) {
                                    NSData(data: data).write(toFile: imageEntity.filePath, atomically: true)
                                }
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { 
                            self.startIndex = 0
                        })
                    }
                } catch {}
            })
        }
    }
    
    //MARK: 手势
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
        
        if let vc = touchedViewController as? PTImageListViewController {
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
    func popViewController(_ vc: PTImageListViewController) -> Void {
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
        rootViewController.push(with: vc, animated: true, direction: .none)
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
                    vc.view.yd_y = UIScreen.main.bounds.size.height - 174
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
                    vc.view.yd_y = UIScreen.main.bounds.size.height - 174
                } else if index == 4 {
                    vc.view.yd_y =  vc.view.yd_height + 60
                }
            }
        }
        if isCollections {
            self.view.sendSubview(toBack: backgroundTitleLabel)
        }
    }
    
    private var _startIndex: Int = 0
    var startIndex: Int {
        set {
            if newValue < 0 || newValue >= self.list.count {
                return
            }
            
            let offset = newValue - _startIndex
            _startIndex = newValue
            
            //往上滑
            if offset > 0 {
                if usedViewControllers.count > 2 && _startIndex > 2 {
                    let vc = usedViewControllers.removeFirst()
                    vc.view.yd_y =  vc.view.yd_height + 10
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
        }
        get {
            return _startIndex
        }
    }
    
    func updateCardsData() -> Void {
        for i in 0 ..< 5 {
            let entityIndex = startIndex < 3 ? i : i + _startIndex - 2
            if entityIndex >= 0 && entityIndex < list.count {
                let patu = list[entityIndex]
                if usedViewControllers.count > 0 && i < usedViewControllers.count {
                    let vc = usedViewControllers[i]
                    vc.updateDataThenView(with: patu.questionId, url: nil)
                }
            }
        }
    }
    
    func updateCards() -> Void {
        
        for i in 0 ..< 5 {
            
            let entityIndex = startIndex < 3 ? i : i + _startIndex - 2
            
            if entityIndex >= 0 && entityIndex < list.count {
                let patu = list[entityIndex]
                if !(usedViewControllers.count > 0 && i < usedViewControllers.count) {
                    weak var ws = self
                    let vc = PTImageListViewController(qid: patu.questionId)
                    vc.blkDeleteClicked = {
                        (c) in
                        guard let strongSelf = ws else {
                            return
                        }
                        YDActionSheetView(title: c.titlView.title, cancleButton: "取消", destructiveButton: "删除", otherButtons: "查看问题", buttonIndex: { (index) in
                            if index == YDActionSheetView.DestructiveBtnTag {
                                YDActionSheetView(title: "确定要删除吗？", cancleButton: "取消", destructiveButton: "删除", otherButtons: nil, buttonIndex: { (index) in
                                    if index == YDActionSheetView.DestructiveBtnTag {
                                        if let i = strongSelf.usedViewControllers.index(of: c) {
                                            guard let forDeletePatu = c.patuEntity else { return }
                                            c.patuEntity = nil
                                            strongSelf.usedViewControllers.remove(at: i)
                                            c.view.removeFromSuperview()
                                            do {
                                                for image in forDeletePatu.imageList {
                                                    if image.owners.count == 1 {
                                                        if FileManager.default.fileExists(atPath: image.filePath) {
                                                            try FileManager.default.removeItem(atPath: image.filePath)
                                                        }
                                                        if FileManager.default.fileExists(atPath: image.headerImagePath) {
                                                            try FileManager.default.removeItem(atPath: image.headerImagePath)
                                                        }
                                                    }
                                                }
                                                try strongSelf.realm.write {
                                                    strongSelf.realm.delete(forDeletePatu)
                                                }
                                            } catch { }
                                            strongSelf.updateCards()
                                        }
                                    }
                                }).show()
                            } else if index == 0 {
                                if let qid = c.patuEntity?.questionId {
                                    _ = ZhuatuService.openZhihuQustionOrAnswer(with: qid)
                                }
                            }
                        }).show()
                    }
                    vc.isSmall = true
                    self.view.addSubview(vc.view)
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

