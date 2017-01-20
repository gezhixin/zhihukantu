//
//  CollectionSelectorListView.swift
//  zhuatu
//
//  Created by gezhixin on 2017/1/19.
//  Copyright © 2017年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

class CollectionSelectorListView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    var list: Results<PatuEntity>!
    
    var tap: UITapGestureRecognizer!
    var pan: UIPanGestureRecognizer!
    
    var dismissBlk: ((_ patu: PatuEntity?, _ isAddNew: Bool) -> Void)?
    
    var contentView: UIView!
    var titleView: UIView!
    var tableView: UITableView!
    
    let contentHeight = CGFloat(330)
    
    static weak var gloableSelectionView: CollectionSelectorListView? = nil
    
    func initUI() -> Void {
        let size = UIApplication.shared.keyWindow!.frame.size
        self.frame = CGRect(origin: CGPoint.zero, size: size)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(onBackgoundTap(tap:)))
        addGestureRecognizer(tap)
        tap.delegate = self
        
        self.backgroundColor = UIColor(hex: 0x0, alpha: 0.0)
        
        contentView = UIView(frame: CGRect(x: 0, y: size.height, width: size.width, height: contentHeight))
        contentView.backgroundColor = UIColor.white
        addSubview(contentView)
        
        titleView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: 30))
        titleView.backgroundColor = UIColor(hex: 0xffffff)
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: size.width - 10, height: 30))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.text = "收藏列表"
        let line = UIView(frame: CGRect(x: 0, y: 29.5, width: self.yd_width, height: 0.5))
        line.backgroundColor = UIColor(hex: 0xeeeeee, alpha: 1)
        titleView.addSubview(titleLabel)
        titleView.addSubview(line)
        contentView.addSubview(titleView)
        
        
        tableView = UITableView(frame: CGRect(x: 0, y: 30, width: size.width, height: contentHeight - 30))
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: 0xeeeeee)
        tableView.dataSource = self
        tableView.delegate = self
        contentView.addSubview(tableView)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onContentViewPan(pan:)))
        tableView.addGestureRecognizer(pan)
        pan.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.yd_height = self.contentView.yd_height - 30
    }
    
    func initData() {
        let realm  = try! Realm()
        list = realm.objects(PatuEntity.self).filter("isCollections = %d", true).sorted(byProperty: "createDate", ascending: false)
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDatasource UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CollectionOptionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CollectionOptionTableViewCell") as? CollectionOptionTableViewCell
        if cell == nil {
            cell = CollectionOptionTableViewCell(style: .default, reuseIdentifier: "CollectionOptionTableViewCell")
        }
        
        if indexPath.row == 0 {
            cell?.titleImageView.image = nil
            cell?.titleLabel.text = "添加新收藏"
            cell?.is4AddColloction = true
        } else {
            let patu = list[indexPath.row - 1]
            if let image = patu.imageList.first {
                cell?.titleImageView.image = UIImage(contentsOfFile: image.filePath)
            }
            cell?.titleLabel.text = patu.title
            cell?.subTitleLabel.text = patu.iamgeCountDesc
            cell?.is4AddColloction = false
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("add collection")
            self.dismiss(patu: nil, isAddNew: true)
        } else {
            let patu = list[indexPath.row - 1]
            self.dismiss(patu: patu)
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tap {
            let point = gestureRecognizer.location(in: self)
            return point.y < contentView.yd_y
        }
        
        if gestureRecognizer == pan {
            let v = pan.velocity(in: self.tableView)
            return tableView.contentOffset.y <= 0 && v.y > 0
        }
        
        return true
    }
    
    //MARK:- Actions
    func onBackgoundTap(tap: UITapGestureRecognizer) -> Void {
        dismiss(patu: nil)
    }
    
    func onContentViewPan(pan: UIPanGestureRecognizer) -> Void {
        let point = pan.translation(in: self)
        if pan.state == .changed {
            let y = self.yd_height - self.contentHeight + point.y
            contentView.frame = CGRect(x: 0, y: y, width: self.yd_width, height: self.yd_height - y)
        } else if pan.state == .ended || pan.state == .failed {
            if contentView.yd_y > self.yd_height - contentHeight + contentHeight * 0.2 {
                self.dismiss(patu: nil, time: 0.1)
            } else {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.contentView.yd_y = self.yd_height - self.contentHeight
                    self.contentView.yd_height = self.contentHeight
                })
            }
        } else if pan.state == .began {
        }
    }
    
    deinit {
        print("CollectionSelectorListView deinit")
    }
    
    class func popoUpWithDismiss(dismissBlk: ((_ patu: PatuEntity?, _ isAddNew: Bool) -> Void)?) {
        if let gloableSelectionView = gloableSelectionView {
            gloableSelectionView.dismiss(patu: nil)
        }
        
        let view = CollectionSelectorListView()
        view.initUI()
        view.initData()
        view.dismissBlk = dismissBlk
        view.show()
        gloableSelectionView = view
    }
    
    func show() {
        let inView = UIApplication.shared.keyWindow!
        if self.superview != nil {
            self.removeFromSuperview()
        }
        
        inView.addSubview(self)
        
        UIView.animate(withDuration: 0.35, animations: { () -> Void in
            self.backgroundColor = UIColor(hex: 0x0, alpha: 0.45)
            self.contentView.yd_y = inView.yd_height - self.contentHeight
        })
    }
    
    func dismiss(patu: PatuEntity?, isAddNew: Bool = false, time: CGFloat = 0.35) -> Void {
         let size = UIApplication.shared.keyWindow!.frame.size
        UIView.animate(withDuration: TimeInterval(time), animations: {
            self.backgroundColor = UIColor(hex: 0x0, alpha: 0.0)
            self.contentView.yd_y = size.height
        }) { (b) in
            self.dismissBlk?(patu, isAddNew)
            self.removeFromSuperview()
        }
    }
}
