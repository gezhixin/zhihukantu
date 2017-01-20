//
//  KZListViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/24.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

class ANSectionData: NSObject {
    var qid: String 
    var title: String 
    var answers: [KZAnswerEntity]
    
    init(qid: String, title: String, answers: [KZAnswerEntity]) {
        self.qid = qid
        self.title = title
        self.answers = answers
    }
}

enum AnswerListDataModel {
    case Answer(KZAnswerEntity)
    case SectionData(ANSectionData)
}

class KZListViewController: BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UI Properties
    var contentView: UIView!
    var titleView: PTTitleView!
    var headerView: UIView!
    var headerImageView: UIImageView!
    var headerLabel: UILabel!
    var tableView: UITableView!
    var freshView: UIButton!
    
    var pan: UIPanGestureRecognizer?
    var titleTap: UITapGestureRecognizer?
    
    var blkDismiss: ((_ c: KZListViewController) -> Void)?
    
    fileprivate var _isSmall: Bool = true
    
    let answerNetwork = KZNetwork()
    
    //MARK: -
    lazy private var _postEntity: KZPostEntity = KZPostEntity()
    var listTokon: NotificationToken?
    
    lazy var tableData: [AnswerListDataModel] = []
    
    //MARK: - Life Cycle
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
        
        headerView = UIView()
        contentView.addSubview(headerView)
        
        headerImageView = UIImageView()
        headerImageView.backgroundColor = UIColor(hex: 0xeeeeee)
        headerView.addSubview(headerImageView)
        
        headerLabel = UILabel()
        headerLabel.textColor = UIColor(hex: 0x555555)
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        tableView.isHidden = true
        contentView.addSubview(tableView)
        
        titleView = PTTitleView(with: nil)
        contentView.addSubview(titleView)
        
        let rBtn = UIButton(type: .system)
        rBtn.setImage(#imageLiteral(resourceName: "icon_fresh"), for: .normal)
        rBtn.tintColor = UIColor(hex: 0x2095f1)
        rBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        rBtn.addTarget(self, action: #selector(onRefreshBtnClikced(_:)), for: .touchUpInside)
        freshView = rBtn
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        listTokon?.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = view.bounds
        
        titleView.frame = CGRect(x: 0, y: 0, width: contentView.yd_width, height: 40)
        
        headerView.frame = CGRect(x: 0, y: 40, width: view.yd_width, height: 1000)
        let contentWidth = headerView.yd_width - 20
        if let image = headerImageView.image {
            headerImageView.frame = CGRect(x: 10, y: 10, width: contentWidth, height: contentWidth * image.size.height / image.size.width)
        } else {
            headerView.frame = CGRect(x: 10, y: 10, width: contentWidth, height: 160)
        }
        let headerLabelSize = _postEntity.excerpt.sizeWith(headerLabel.font, width: contentWidth)
        headerLabel.frame = CGRect(origin: CGPoint(x: 10, y: headerImageView.yd_bottom + 10), size: headerLabelSize)
        headerView.yd_height = headerLabel.yd_bottom + 10
        
        tableView.frame = contentView.bounds
    }
    
    //MARK: - UI
    func addCancelBtn() -> Void {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        btn.addTarget(self, action: #selector(self.onCancelBtnClicked(sender:)), for: .touchUpInside)
        titleView.leftItem = btn
    }
    
    private func updateHeaderView() -> Void {
        weak var weakSelf = self
        headerImageView.sd_setImage(with: URL(string: _postEntity.pic))
        headerImageView.sd_setImage(with: URL(string: _postEntity.pic)) { ( _, _, _, _) in
            weakSelf?.viewDidLayoutSubviews()
        }
        headerLabel.text = _postEntity.excerpt
        titleView.title = _postEntity.title
    }
    
    private func updateTableView() {
        tableView.isUserInteractionEnabled = false
        tableData.removeAll()
        var sectionArr: [ANSectionData] = []
        for answer in postEntity.anwserList {
            var isAlreadyHadSection = false
            for answerSectionData in sectionArr {
                if answer.questionid == answerSectionData.qid {
                    answerSectionData.answers.append(answer)
                    isAlreadyHadSection = true
                    break
                }
            }
            if isAlreadyHadSection {
                continue
            }
            
            let sectiondata = ANSectionData(qid: answer.questionid, title: answer.title, answers: [answer])
            sectionArr.append(sectiondata)
        }
        
        for sectionData in sectionArr {
            tableData.append(AnswerListDataModel.SectionData(sectionData))
            for answer in sectionData.answers {
                tableData.append(AnswerListDataModel.Answer(answer))
            }
        }
        
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
    }
    
    //MARK: - Actions
    func onCancelBtnClicked(sender: UIButton?) -> Void {
        self.blkDismiss?(self)
    }
    
    func addAnswerListListener() -> Void {
        weak var weakSelf = self
        listTokon = _postEntity.anwserList.addNotificationBlock({ (changes) in
            guard let strongSelf = weakSelf else { return }
            switch changes {
            case .initial(let value):
                strongSelf.updateTableView()
                break
            case .update(_, _, _, _):
                strongSelf.updateTableView()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        })
    }
   
    //MARK: 手势
    func onTitleTap(_ tap: UITapGestureRecognizer) -> Void {
        if tableData.count != 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
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
            if (abs(v.x) / abs(v.y) > 1.93 || (abs(v.y) > abs(v.x) && v.y > 0 && tableView.contentOffset.y <= 0)) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    //MARK: - Setter Getter
    var postEntity: KZPostEntity {
        set {
            if _postEntity == newValue {
                return
            }
            
            _postEntity = newValue
            
            updateHeaderView()
            if _postEntity.anwserList.count == 0 {
                fethcAnswerList()
            }
        }
        get {
            return _postEntity
        }
    }
    
    var isSmall: Bool {
        set {
            _isSmall = newValue
            if _isSmall {
                titleView.leftItem = nil
                titleView.rightItem = nil
                if pan != nil {
                    view.removeGestureRecognizer(pan!)
                    pan = nil
                }
                if titleTap != nil {
                    titleView.removeGestureRecognizer(titleTap!)
                    titleTap = nil
                }
                self.tableView.isHidden = true
                self.headerView.isHidden = false
            } else {
                updateTableView()
                self.addCancelBtn()
                
                if tableData.count != 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
                
                self.tableView.isHidden = false
                self.headerView.isHidden = true
                
                if pan == nil {
                    pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPanAction(_:)))
                    pan?.delegate = self
                    tableView.panGestureRecognizer.require(toFail: pan!)
                }
                view.addGestureRecognizer(pan!)
               
                if titleTap == nil {
                    titleTap = UITapGestureRecognizer(target: self, action: #selector(self.onTitleTap(_:)))
                }
                titleView.addGestureRecognizer(titleTap!)
                
                
                if _postEntity.anwserList.count == 0 {
                    fethcAnswerList()
                }
            }
        }
        get {
            return _isSmall
        }
    }
    
    //MARK: - Actions
    func onRefreshBtnClikced(_ sender: UIButton) -> Void {
        fethcAnswerList()
    }
    
    func refresh(animated: Bool) -> Void {
        
        guard let refreshBtn = self.freshView else {
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
            refreshBtn.tintColor = UIColor(hex: 0x2095f1)
            refreshBtn.imageView?.layer.removeAllAnimations()
        }
    }
    
    func fethcAnswerList() -> Void {
        if freshView.tintColor == iconFreshingColor {
            return
        }
        
        refresh(animated: true)
        weak var weakSelf = self
        answerNetwork.getAnswerList(with: _postEntity, success: {
            weakSelf?.refresh(animated: false)
            }, failed: { (errorCode, errorMsg) in
                weakSelf?.refresh(animated: false)
                if weakSelf?.isSmall == false {
                    weakSelf?.titleView.rightItem = weakSelf?.freshView
                    _ = ZXTopPromptView.showWarning(tips: errorMsg, isSmall: true, dissmiss: nil)
                }
        })
    }
    
    //MARK: - UITableView DataSource Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableData[indexPath.row]
        switch data {
        case .Answer(_):
            return KZAnswerTableViewCell.cellHeight
        case .SectionData(_):
            return KZQuestionTitleTableViewCell.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = tableData[indexPath.row]
        
        switch data {
        case .Answer(let answer):
            var cell: KZAnswerTableViewCell? = tableView.dequeueReusableCell(withIdentifier: KZAnswerTableViewCell.identifier) as? KZAnswerTableViewCell
            if cell == nil {
                cell = KZAnswerTableViewCell()
                cell?.blkHeaderClicked = { (cell) in
                    _ = ZhuatuService.openPeopleHomePage(with: cell.anserEntity.authorhash)
                }
            }
            cell?.anserEntity = answer
            
            return cell!
        case .SectionData(let sectionData):
            var cell: KZQuestionTitleTableViewCell? = tableView.dequeueReusableCell(withIdentifier: KZQuestionTitleTableViewCell.identifier) as? KZQuestionTitleTableViewCell
            if cell == nil {
                cell = KZQuestionTitleTableViewCell()
            }
            cell?.sectionData = sectionData
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = tableData[indexPath.row]
        
        switch data {
        case .Answer(let answer):
            _ = ZhuatuService.openZhihuQustionOrAnswer(with: answer.questionid, aid: answer.answerid)
            break
        case .SectionData(let sectionData):
            _ = ZhuatuService.openZhihuQustionOrAnswer(with: sectionData.qid)
            break
        }
    }
    
}
