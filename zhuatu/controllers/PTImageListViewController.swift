//
//  PTImageListViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation
import RealmSwift

class PTImageListViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, KNPhotoBrowerDataSource, KNPhotoBrowerDelegate, UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate {
    
    var qid: String?
    var url: String?
    
    var titlView: PTTitleView!
    
    var collectionView: UICollectionView!
    var bottomMenuView: UIVisualEffectView!
    var bottomLabel: UILabel!
    var popoUpContent: Popover?
    var shareBtn: UIButton!
    var contentView: UIView!
    
    var patuEntity: PatuEntity?
    var realm: Realm!
    
    var listToken: NotificationToken? = nil
    var zhuatuService: ZhuatuService!
    
    var isOnEditing: Bool = false
    
    var selectedImages: [ImageEntity] = []
    
    var preSaveToPhotoBookImages: [UIImage] = []
    var preShareImages: [UIImage] = []
    
    var isQuestion: Bool = true
    
    var pan: UIPanGestureRecognizer?
    var titleTap: UITapGestureRecognizer?
    
    var blkDismiss: ((_ c: PTImageListViewController) -> Void)?
    var blkDeleteClicked: ((_ c: PTImageListViewController) -> Void)?
   
    var deleteBtn: UIButton?
    var coverControl: UIControl?
    fileprivate var _isSmall: Bool = false
    var isSmall: Bool {
        set {
            _isSmall = newValue
            if _isSmall {
                if let coverControl = self.coverControl {
                    view.addSubview(coverControl)
                } else {
                    coverControl = UIControl(frame: view.bounds)
                    view.addSubview(coverControl!)
                    coverControl?.addTarget(self, action: #selector(self.onCoverClikced(_:)), for: .touchUpInside)
                    coverControl?.frame = view.bounds
                    view.addSubview(coverControl!)
                }
                
                if let deleteBtn = self.deleteBtn {
                    view.addSubview(deleteBtn)
                } else {
                    deleteBtn = UIButton(type: .system)
                    deleteBtn?.tintColor = UIColor.red
                    deleteBtn?.setImage(#imageLiteral(resourceName: "icon_menu"), for: .normal)
                    deleteBtn?.addTarget(self, action: #selector(self.onDeleteBtnClicked(_:)), for: .touchUpInside)
                    view.addSubview(deleteBtn!)
                }
                
                if isOnEditing {
                    onRightMenuAction(UIButton())
                }
                titlView.rightItem = nil
                titlView.leftItem = nil
                if pan != nil {
                    view.removeGestureRecognizer(pan!)
                    pan = nil
                }
            } else {
                self.coverControl?.removeFromSuperview()
                self.deleteBtn?.removeFromSuperview()
                setRightMenuToNormal()
                setLeftBarItem()
                if pan == nil {
                    pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPanAction(_:)))
                    pan?.delegate = self
                    collectionView.panGestureRecognizer.require(toFail: pan!)
                }
                view.addGestureRecognizer(pan!)
            }
        }
        get {
            return _isSmall
        }
    }
    
    var bLabel: UILabel!
    
    //MARK: - Life Cycle
    convenience init(qid: String, url: String? = nil) {
        self.init()
        
        guard let realm = try? Realm() else { return }
        self.realm = realm
        
        title = "看美图"
        
        zhuatuService = ZhuatuService()
        
        _ = self.updateData(with: qid, url: url)
    }
    
    deinit {
        zhuatuService.cancelAll()
        listToken?.stop()
        collectionView.removeObserver(self, forKeyPath: "contentSize")
         collectionView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 18
        view.layer.shadowOpacity = 0.2
        
        contentView = UIView(frame: self.view.bounds)
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        view.addSubview(contentView)
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.white
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        
        let w = collectionView.yd_width / 3
        layout.itemSize = CGSize(width: w, height: w + 2)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.register(SmallImageCollectionViewCell.self, forCellWithReuseIdentifier: "SmallImageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        
        bottomMenuView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        bottomMenuView.frame = CGRect(x: 0, y: view.yd_height + 2, width: view.yd_width, height: 50)
        contentView.addSubview(bottomMenuView)
        
        
        weak var weakSelf = self
        let shareBtn = UIButton { (index, btn) in
            guard let strongSelf = weakSelf else { return }
            let menuView = PopuMenuView(frame: CGRect(x: 0, y: 0, width: 130, height: 40))
            menuView.options = ["保存相册", "更多选项"]
            menuView.contentView.backgroundColor = UIColor(hex: 0, alpha: 0.3)
            weak var wwSelf = strongSelf
            menuView.bklOptionClicked = {
                (btn) in
                guard let strongSelf = wwSelf else { return }
                if let title = btn.titleLabel?.text {
                    switch title {
                    case "保存相册":
                        strongSelf.popoUpContent?.dismiss()
                        strongSelf.saveSelectImagesToPhotoBook()
                        break
                    case "更多选项":
                        strongSelf.popoUpContent?.dismiss()
                        strongSelf.shareWithActiveVC()
                        break
                    default:
                        break
                    }
                }
            }
            if strongSelf.popoUpContent == nil {
                let options = [
                    .type(.up),
                    .cornerRadius(3),
                    .animationIn(0.3),
                    .sideEdge(10),
                    .blackOverlayColor(UIColor.clear),
                    .color(UIColor.black.withAlphaComponent(0.3)),
                    .offset(10),
                    ] as [PopoverOption]
                strongSelf.popoUpContent = Popover(options: options, showHandler: nil, dismissHandler: {
                    
                })
            }
            var point = strongSelf.shareBtn.convert(strongSelf.shareBtn.center, to: strongSelf.view)
            point.y -= (strongSelf.shareBtn.yd_height / 2 - 26)
            strongSelf.popoUpContent?.show(menuView, point: point)
        }
        self.shareBtn = shareBtn
        shareBtn.setImage(UIImage(named: "icon_menu"), for: UIControlState())
        shareBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
        bottomMenuView.addSubview(shareBtn)
        
        let deleteBtn = UIButton { (index, btn) in
            guard let strongSelf = weakSelf else { return }
            while strongSelf.selectedImages.count > 0 {
                do {
                    if let image = strongSelf.selectedImages.last {
                        guard let imageIndex = strongSelf.patuEntity?.imageList.index(of: image) else {
                            continue
                        }
                        if image.owners.count == 1 {
                            if FileManager.default.fileExists(atPath: image.filePath) {
                                try FileManager.default.removeItem(atPath: image.filePath)
                            }
                            try strongSelf.realm.write({
                                strongSelf.patuEntity?.imageList.remove(objectAtIndex: imageIndex)
                                strongSelf.realm.delete(image)
                                
                            })
                        } else {
                            try strongSelf.realm.write({
                                strongSelf.patuEntity?.imageList.remove(objectAtIndex: imageIndex)
                            })
                        }
                    }
                    strongSelf.selectedImages.removeLast()
                } catch {
                    print("delete iamge error")
                    break
                }
            }
            strongSelf.bottomLabel.text = strongSelf.selectedImages.count > 0 ? "已选择（\(strongSelf.selectedImages.count)）" : nil
        }
        deleteBtn.setImage(UIImage(named: "icon_delete"), for: UIControlState())
        deleteBtn.frame = CGRect(x: bottomMenuView.yd_width - 60, y: 0, width: 60, height: 50)
        bottomMenuView.addSubview(deleteBtn)
        
        bottomLabel = UILabel(frame: CGRect(x: 100, y: 0, width: bottomMenuView.yd_width - 200, height: 50))
        bottomLabel.font = UIFont.systemFont(ofSize: 14)
        bottomLabel.textAlignment = .center
        bottomMenuView.addSubview(bottomLabel)
        
        addBottomLabel()
        
        titlView = PTTitleView(with: nil)
        contentView.addSubview(titlView)
        
        self.isSmall = false
        
        titleTap = UITapGestureRecognizer(target: self, action: #selector(self.onTitleTap(_:)))
        titlView.addGestureRecognizer(titleTap!)
        
        if (self.traitCollection.forceTouchCapability != .available) {
            let loongTap = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongTap(_:)))
            self.view.addGestureRecognizer(loongTap)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        weak var weakSelf = self
        if self.patuEntity?.imageList.count == 0 {
            do {
                try realm.write({
                    guard let strongSelf = weakSelf else { return }
                    realm.delete(strongSelf.patuEntity!)
                })
            } catch {}
            self.patuEntity = nil
            return
        } else {
            guard let first = self.patuEntity?.imageList.first else { return }
            let lastOffset = self.zhuatuService.lastOffset
            do {
                try realm.write({
                    guard let strongSelf = weakSelf else { return }
                    strongSelf.patuEntity?.lastOffset = lastOffset
                    strongSelf.patuEntity?.titleImageName = first.name
                    strongSelf.patuEntity?.subTitle = "共 \(strongSelf.patuEntity!.imageList.count) 张"
                })
            } catch {}
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = view.bounds
        self.collectionView.frame = self.view.bounds
        let w = collectionView.yd_width / 3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: w, height: w + 2)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        titlView.frame = CGRect(x: 0, y: 0, width: view.yd_width, height: 40)
        
        if let coverControl = self.coverControl {
            coverControl.frame = view.bounds
        }
        
        if let deleteBtn = self.deleteBtn {
            deleteBtn.frame = CGRect(x: view.yd_width - 40, y: 0, width: 40, height: 40)
            self.view.bringSubview(toFront: deleteBtn)
        }
        
    }
    
    func updateView() -> Void {
        
        guard let patuEntity = self.patuEntity else {
            return
        }
        
        if !patuEntity.isQuestion {
            if let first = patuEntity.imageList.first {
                titlView.title = (first.userName.isEmpty ? "" : (first.userName + " ：")) + patuEntity.title
            }
        } else {
            titlView.title = patuEntity.title
        }
        
        if patuEntity.isGuid || patuEntity.isCollections {
            collectionView.reloadData()
            bLabel.text = "没有了"
            return
        }
        
        if patuEntity.isQuestion && patuEntity.imageList.count > 18 {
            collectionView.reloadData()
            bLabel.text = "上拉下载图片"
            return
        }
        
        weak var weakSelf = self
        weak var weakZhuatuServ = zhuatuService
        weak var weakEntity = patuEntity
        
        bLabel.text = "加载中……"
        ZhuatuService.getTitleFromHtml(patuEntity.url) { (title, html) in
            guard let strongSelf = weakSelf else { return }
            guard let strongEntity = weakEntity else { return }
            if let html = html {
                weak var wSelf = strongSelf
                weakZhuatuServ?.downLoadIamgesFromHtml(html, complated: { (finished) in
                    guard let strongSelf = wSelf else { return }
                    
                    if (!strongSelf.isQuestion) {
                        strongSelf.bLabel.text = "没有了"
                        return
                    }
                    
                    if strongEntity.imageList.count < 20 && strongSelf.isQuestion  {
                        
                        weakZhuatuServ?.getImageFromQuestionWitId(strongSelf.qid!, complated: { (finished) in
                            if (finished) {
                                weakSelf?.bLabel.text = "没有了"
                            } else {
                                weakSelf?.bLabel.text = "上拉下载图片"
                            }
                        })
                    } else {
                        weakSelf?.bLabel.text = "上拉下载图片"
                    }
                })
            }
            if patuEntity.title.isEmpty {
                strongSelf.titlView.title = title
                if let title = title {
                    do {
                        try strongSelf.realm.write({
                            patuEntity.title = title
                        })
                    } catch {}
                }
            }
        }
        collectionView.reloadData()
    }
    
    func updateData(with qid: String, url: String?) -> Bool {
        
        if self.qid == qid {
            return false
        }
        
        
        isQuestion = !qid.isEmpty
        
        self.qid = qid
        self.url = url
        
        if qid.isEmpty && self.url != nil {
            self.qid = self.url!.md5()
        }
        
        var realUrl = ""
        if let url = self.url {
            realUrl = url
        } else {
            realUrl = ZhihuNetwork.questionUrlWithId(qid)
        }
        
        if let patu = realm.objects(PatuEntity.self).filter("questionId = %@", self.qid!).first {
            self.patuEntity = patu
            self.isQuestion = patu.isQuestion
        } else {
            let patuEntity = PatuEntity()
            patuEntity.questionId = self.qid!
            patuEntity.isQuestion = self.isQuestion
            patuEntity.url = realUrl
            do {
                try realm.write({ () -> Void in
                    realm.add(patuEntity, update: true)
                })
            } catch {
                print("database error")
            }
            self.patuEntity = patuEntity
            
        }
        self.addRealmNofi()
        
        guard let patuEntity = self.patuEntity else {
            return false
        }

        isQuestion = patuEntity.isQuestion
        
        
        zhuatuService.qid = self.qid!
        zhuatuService.lastOffset = patuEntity.lastOffset
        
        return true
    }
    
    func updateDataThenView(with qid: String, url: String?) -> Void {
        if self.updateData(with: qid, url: url) {
            self.updateView()
        }
    }
    
    //MARK: - 数据库监听
    func addRealmNofi() {
        weak var weakSelf = self
        
        listToken = self.patuEntity?.imageList.addNotificationBlock({ (changes) in
            guard let strongSelf = weakSelf else { return }
            guard let collectionView = strongSelf.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                if insertions.count > 0 {
                    collectionView.insertItems(at: insertions.map{(NSIndexPath(row: $0, section: 0) as IndexPath)})
                }
                if deletions.count > 0 {
                    collectionView.reloadData()
                }
                if modifications.count > 0 {
                    collectionView.reloadItems(at: modifications.map{NSIndexPath(row: $0, section:0) as IndexPath})
                }
                if !strongSelf.isQuestion {
                    if let first = strongSelf.patuEntity?.imageList.first {
                        strongSelf.titlView.title = (first.userName.isEmpty ? "" : (first.userName + " ：")) + strongSelf.patuEntity!.title
                    }
                }
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        })
    }
    
    
    //MARK: - 手势
    func onLongTap(_ tap: UILongPressGestureRecognizer) -> Void {
        
        if isOnEditing  {
            return
        }
        
        guard let patuEntity = self.patuEntity else { return }
        
        let point = tap.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            if (indexPath as NSIndexPath).row >= 0 && indexPath.row < patuEntity.imageList.count {
                let imageEntity = patuEntity.imageList[indexPath.row]
                
                weak var wSelf = self
                MyPeekView.show(with: imageEntity, dismiss: { (imageEntity, btn) in
                    if let imageEntity = imageEntity, let btnTitle = btn?.titleLabel?.text {
                        switch btnTitle {
                        case "查看答案":
                            _ = ZhuatuService.openZhihuQustionOrAnswer(with: imageEntity.questionId, aid: imageEntity.answerId) 
                            break
                        case "个人主页":
                            _ = ZhuatuService.openPeopleHomePage(with: imageEntity.userId) 
                            break
                        case "分享":
                            if let image = UIImage(contentsOfFile: imageEntity.filePath) {
                                wSelf?.preShareImages.append(image)
                                wSelf?.shareWithActiveVC()
                            }
                            break
                        default:
                            break
                        }
                    }
                })
            }
        }
    }
    
    //MARK: - 菜单
    func setLeftBarItem() -> Void {
        let barItem = UIButton(type: .system)
        barItem.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        barItem.addTarget(self, action: #selector(self.onLiftBarClicked(_:)), for: .touchUpInside)
        barItem.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        titlView.leftItem = barItem
    }
    
    func setRightMenuToNormal() -> Void {
        let barItem = UIButton(type: .system)
        barItem.setTitle("选择", for: .normal)
        barItem.addTarget(self, action: #selector(self.onRightMenuAction(_:)), for: .touchUpInside)
        barItem.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        titlView.rightItem = barItem
    }
    
    func setRightMenuToEditing() -> Void {
        let barItem = UIButton(type: .system)
        barItem.setTitle("取消", for: .normal)
        barItem.addTarget(self, action: #selector(self.onRightMenuAction(_:)), for: .touchUpInside)
        barItem.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        titlView.rightItem = barItem
    }
    
    func onLiftBarClicked(_ btn: UIButton?) -> Void {
        self.blkDismiss?(self)
    }
    
    func onRightMenuAction(_ sender: UIButton?) -> Void {
        self.isOnEditing = !self.isOnEditing
        
        if self.isOnEditing {
            self.setRightMenuToEditing()
            collectionView.reloadData()
        } else {
            self.setRightMenuToNormal()
            self.selectedImages.removeAll()
            bottomLabel.text = self.selectedImages.count > 0 ? "已选择（\(self.selectedImages.count)）" : nil
            collectionView.reloadData()
        }
        
        let y = isOnEditing ? view.yd_height - bottomMenuView.yd_height : view.yd_height + 2
        
        UIView.animate(withDuration: 0.35, animations: { 
            self.bottomMenuView.yd_y = y
        }) 
    }
    
    //MARK: - Actions
    func onDeleteBtnClicked(_ sender: UIButton) -> Void {
        self.blkDeleteClicked?(self)
    }
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let patuEntity = self.patuEntity else {
            return 0
        }
        return patuEntity.imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let patuEntity = self.patuEntity else {
            return UICollectionViewCell()
        }

        let cell: SmallImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallImageCollectionViewCell", for: indexPath) as! SmallImageCollectionViewCell
        if #available(iOS 9.0, *) {
            if (self.traitCollection.forceTouchCapability == .available) {
                self.registerForPreviewing(with: self, sourceView: cell)
            }
        }
        let image = patuEntity.imageList[indexPath.row]
        
        cell.imageView.image = UIImage(contentsOfFile: image.filePath)
        cell.isEditing = self.isOnEditing
        if let _ = self.selectedImages.index(where: { (im) -> Bool in
            return im.name == image.name
        }) {
            cell.isOnSelected = true
        } else {
            cell.isOnSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let patuEntity = self.patuEntity else {
            return
        }

        let imageEntity = patuEntity.imageList[indexPath.row]
        if self.isOnEditing {
            if let index = self.selectedImages.index(where: { (im) -> Bool in
                return im.name == imageEntity.name
            }) {
                self.selectedImages.remove(at: index)
            } else {
                self.selectedImages.append(imageEntity)
            }
            bottomLabel.text = self.selectedImages.count > 0 ? "已选择（\(self.selectedImages.count)）" : nil
            collectionView.reloadItems(at: [indexPath])
        } else {
            let brower = KNPhotoBrower()
            brower.currentIndex = (indexPath as NSIndexPath).row
            brower.actionSheetArr = ["删除", "保存到相册"]
            brower.dataSource = self
            brower.delegate = self
            brower.present()
        }
    }
    
    func laodMore() {
        if self.isOnEditing || !isQuestion {
            return
        }
        
        weak var weakSelf = self
        self.zhuatuService.blkComplated = {
            (finished) in
            var insets = weakSelf?.collectionView.contentInset
            insets?.bottom = 0
            weakSelf?.collectionView.contentInset = insets!
            if finished {
                weakSelf?.bLabel.text = "没有了"
            } else {
                weakSelf?.bLabel.text = "上拉下载图片"
            }
        }
        self.zhuatuService.loadMore()
    }
    
    //MARK: - 保存到相册 分享
    func shareWithActiveVC()  {
        
        for imageEntity in selectedImages {
            if let image = UIImage(contentsOfFile: imageEntity.filePath) {
                preShareImages.append(image)
            }
        }
        
        if self.preShareImages.count == 0 {
           _ = ZXTopPromptView.showWarning(tips: "没有选中的图片！\n☹️")
            return
        }
        
        var images: [UIImage] = []
        images.append(contentsOf: preShareImages)
        
        preShareImages.removeAll()
        
        if images.count == 0 {
            _ = ZXTopPromptView.showWarning(tips: "没有选中的图片！\n☹️")
            return
        }
        
        let activeVC = UIActivityViewController(activityItems: images, applicationActivities: nil)
        self.present(activeVC, animated: true) { 
            
        }
    }
    
    func saveSelectImagesToPhotoBook() {
        if self.selectedImages.count == 0 {
            _ = ZXTopPromptView.showWarning(tips: "没有选中的图片！\n☹️")
            return
        }
        
        for imageEntity in self.selectedImages {
            if let image = UIImage(contentsOfFile: imageEntity.filePath) {
                self.preSaveToPhotoBookImages.append(image)
            }
        }
        
        if preSaveToPhotoBookImages.count > 0 {
            startPathSaveToPhotoBook()
        }
    }
    
    func startPathSaveToPhotoBook() {
        if let image = self.preSaveToPhotoBookImages.last {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        
        if didFinishSavingWithError != nil {
            _ = ZXTopPromptView.showWarning(tips: "保存失败！\n☹️")
            preSaveToPhotoBookImages = []
            return
        }
        
        preSaveToPhotoBookImages.removeLast()
        if preSaveToPhotoBookImages.count > 0 {
            self.startPathSaveToPhotoBook()
        } else {
            _ = ZXTopPromptView.showSuccess(tips: "保存成功！\n😀")
        }
    }
    
    
    //MARK: - photoBrower
    func photoBrower(_ brower: KNPhotoBrower!, menuClikedAtPage page: Int) {
        guard let patuEntity = self.patuEntity else {
            return
        }
        
        if page >= 0 && page < patuEntity.imageList.count {
            let image = patuEntity.imageList[page]
            if  image.userId.isEmpty {
                YDActionSheetView(title: image.userName.isEmpty ? nil : image.userName, cancleButton: "取        消", destructiveButton: "删        除", otherButtons: "查看答案", "保存图片", buttonIndex: { (index) in
                    if index == YDActionSheetView.DestructiveBtnTag {
                        self.deleteImage(image)
                        brower.reload()
                    } else if index == 0 {
                        _ = ZhuatuService.openZhihuQustionOrAnswer(with: image.questionId, aid: image.answerId)
                    } else if index == 1 {
                        self.saveImage(imageItem: image)
                    }
                }).show()
            } else {
                YDActionSheetView(title: image.userName.isEmpty ? nil : image.userName, cancleButton: "取        消", destructiveButton: "删        除", otherButtons: "查看回答", "个人主页", "保存图片", buttonIndex: { (index) in
                    if index == YDActionSheetView.DestructiveBtnTag {
                        self.deleteImage(image)
                        brower.reload()
                    } else if index == 0 {
                        _ = ZhuatuService.openZhihuQustionOrAnswer(with: image.questionId, aid: image.answerId)
                    } else if index == 1 {
                        _ = ZhuatuService.openPeopleHomePage(with: image.userId)
                    } else if index == 2 {
                        self.saveImage(imageItem: image)
                    }
                }).show()
            }
        }
        
    }
    
    func photoBrower(_ brower: KNPhotoBrower!, collectClikedAtPage page: Int) {
        CollectionSelectorListView.popoUpWithDismiss { (patu, isAddNew) in
            if isAddNew && patu == nil {
                let box = CreateOnePatuBox(dismiss: { (isCreate, text) in
                    print("CreateOnePatuBox  \(isCreate)  \(text)")
                    if isCreate {
                        print("Create")
                        if let title = text {
                            print("Create 1")
                            if let _ = self.realm.objects(PatuEntity.self).filter("questionId = %@", title.md5()).first {
                                _ = ZXTopPromptView.showWarning(tips: "名称重复了😕", isSmall: true)
                            } else {
                                print("Create2")
                                let newPatu = PatuEntity()
                                newPatu.title = title
                                newPatu.isCollections = true
                                newPatu.questionId = title.md5()
                                do{
                                    if let image = self.patuEntity?.imageList[page] {
                                        try Realm().write {
                                            try Realm().add(newPatu)
                                            newPatu.imageList.append(image)
                                        }
                                        _ = ZXTopPromptView.showSuccess(tips: "图片收藏好了🙂", isSmall: true)
                                    }
                                } catch {}
                            }
                        }
                    }
                })
                box.emptyWarningText = "需要一个主题呀😕"
                box.placeHolder = "添加一个收藏主题"
                box.buttonTitle = "创  建"
                box.textfield.keyboardType = .default
                box.show()
            } else if let patu = patu {
                if let image = self.patuEntity?.imageList[page] {
                    if let _ = patu.imageList.filter("name = %@", image.name).first {
                        _ = ZXTopPromptView.showSuccess(tips: "图片收藏好了🙂", isSmall: true)
                        return
                    }
                    do{
                       try Realm().write {
                            patu.imageList.append(image)
                        }
                    } catch {}
                    _ = ZXTopPromptView.showSuccess(tips: "图片收藏好了🙂", isSmall: true)
                }
            } else {
                print("add collection cancel")
            }
        }
    }

    
    func deleteImage(_ image: ImageEntity)  {
        if image.owners.count == 1 {
            do {
                if FileManager.default.fileExists(atPath: image.filePath) {
                    try FileManager.default.removeItem(atPath: image.filePath)
                }
                try self.realm.write({ [weak self] in
                    self?.realm.delete(image)
                })
            } catch { }
        } else {
            do {
                try self.realm.write({ [weak self] in
                    if let index = self?.patuEntity?.imageList.index(of: image) {
                        self?.patuEntity?.imageList.remove(objectAtIndex: index)
                    }
                })
            } catch { }
        }
    }
    
    func saveImage(imageItem: ImageEntity) {
        if let image = UIImage(contentsOfFile: imageItem.filePath) {
            preSaveToPhotoBookImages = [image]
            self.startPathSaveToPhotoBook()
        } else {
            _ = ZXTopPromptView.showWarning(tips: "保存失败！\n☹️")
        }
    }
    
    func photoBrower(_ view: KNPhotoBrower!, currentBackImageView index: Int) -> UIImageView! {
        if let cell: SmallImageCollectionViewCell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? SmallImageCollectionViewCell {
            return cell.imageView
        } else {
            return UIImageView()
        }
    }
    
    func photoBrower(_ view: KNPhotoBrower!, showedAt index: Int) {
        
        if bLabel.text == "加载中……" {
            return
        }
        
        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition.centeredVertically, animated: false)
    }
    
    func photoBrowerItemCount() -> Int32 {
        guard let patuEntity = self.patuEntity else {
            return 0
        }

        return Int32(patuEntity.imageList.count)
    }
    
    func photoBrower(_ veiw: KNPhotoBrower!, iamgeFilePathAt index: Int32) -> String! {
        guard let patuEntity = self.patuEntity else {
            return ""
        }

        if Int(index) < patuEntity.imageList.count {
            let imageEntity = patuEntity.imageList[Int(index)]
            return imageEntity.filePath
        } else {
            return ""
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            bLabel.yd_y = collectionView.contentSize.height
        }
        
        if keyPath == "contentSize" {
            if bLabel.text == "加载中……" || bLabel.text == "没有了" {
                return
            }
            
            if collectionView.isDragging {
                if collectionView.contentOffset.y + collectionView.yd_height - 50 > collectionView.contentSize.height && !isOnEditing {
                    bLabel.text = "松手我就去下载图片了"
                } else{
                    bLabel.text = "上拉下载图片"
                }
                bLabel.yd_height = max(collectionView.contentOffset.y + collectionView.yd_height - collectionView.contentSize.height, 30)
            } else {
                if bLabel.text == "松手我就去下载图片了" {
                    bLabel.text = "加载中……"
                    var insets = collectionView.contentInset
                    insets.bottom = 30
                    collectionView.contentInset = insets
                    self.laodMore()
                }
                bLabel.yd_height = 30
            }
        }
    }
    
    func addBottomLabel() -> Void {
        let label = UILabel(frame: CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.yd_width, height: 30))
        label.textAlignment = .center
        label.textColor = UIColor(hex: 0x666666)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "上拉下载图片"
        collectionView.addSubview(label)
        bLabel = label
    }
    
    //MAKR: - Cover 
    func onCoverClikced(_ sender: UIControl) -> Void {
        
    }
    
    //MARK: - 3D Touch
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if self.isOnEditing {
            return nil
        }
        
        if let presVc = self.presentedViewController {
            if (presVc.isKind(of: ImagePeekPreViewController.self))
            {
                return nil;
            }
        }
        
        if #available(iOS 9.0, *) {
            guard let cell: SmallImageCollectionViewCell = previewingContext.sourceView as? SmallImageCollectionViewCell else { return nil }
            guard let indexPath = collectionView.indexPath(for: cell) else { return nil }
            guard let patuEntity = self.patuEntity else {
                return nil
            }

            
            let imageEntity = patuEntity.imageList[indexPath.row]
            
            let vc = ImagePeekPreViewController(imageEntity: imageEntity)
            vc.backViewContoller = self
            vc.preferredContentSize = CGSize(width: 0.0, height: 400)
            
            previewingContext.sourceRect = cell.bounds
            
            return vc
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
    
    //MARK: - 手势
    func onTitleTap(_ tap: UITapGestureRecognizer) -> Void {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func onPanAction(_ pan: UIPanGestureRecognizer) -> Void {
        let point = pan.translation(in: self.view)
        if pan.state == .changed {
            view.frame = CGRect(x: point.x, y:24 + point.y, width: view.yd_width, height: view.yd_height)
        } else if pan.state == .ended || pan.state == .failed {
            if abs(point.x) > 80 || abs(point.y) > 80 {
                blkDismiss?(self)
            } else {
                UIView.animate(withDuration: 0.25, animations: { 
                    self.view.frame = CGRect(x: 0, y: 24, width: self.view.yd_width, height: self.view.yd_height)
                })
            }
        } else if pan.state == .began {
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pan {
            let v = pan!.velocity(in: self.view)
            if (abs(v.x) / abs(v.y) > 1.93 || (abs(v.y) > abs(v.x) && v.y > 0 && collectionView.contentOffset.y <= 0)) && !self.isOnEditing {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
