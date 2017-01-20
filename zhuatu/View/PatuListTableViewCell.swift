//
//  PatuListTableViewCell.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

@objc protocol PatuListTableViewCellDelegate: YDBackMenuCellDelegate {
    func patuListTableViewCell(_ cell: PatuListTableViewCell, deleteBtnClicked: UIButton)
}

class PatuListTableViewCell: YDBackMenuTableViewCell {

    var titleImageView: UIImageView!
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        let width = UIScreen.main.bounds.size.width
        self.frame = CGRect(x: 0, y: 0, width: width, height: 60)
        
        self.ydContentView = self.contentView
        self.backMenuWidth = 60
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor(hex: 0xeeeeee)
        
        weak var weakSelf = self
        let btn = UIButton { (index, btn) in
            guard let strongSelf = weakSelf else { return }
            strongSelf.onDeleteBtnClicked(btn)
        }
        btn.setImage(UIImage(named: "icon_delete"), for: UIControlState())
        btn.frame = CGRect(x: self.yd_width - 60, y: 0, width: 60, height: 60)
        self.insertSubview(btn, belowSubview: contentView)
        
        titleImageView = UIImageView(frame: CGRect(x: 15, y: 5, width: 50, height: 50))
        titleImageView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        titleImageView.layer.masksToBounds = true
        titleImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(titleImageView)
        
        
        titleLabel = UILabel(frame: CGRect(x: 70, y: 5, width: width - 80, height: 20))
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(hex: 0x333333)
        
        subTitleLabel = UILabel(frame: CGRect(x: 70, y: 35, width: width - 80, height: 15))
        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.textColor = UIColor(hex: 0x666666)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? UIColor(hex: 0xeeeeee) : UIColor.white
    }
    
    override func setMyContentViewX(_ x: CGFloat) {
        
        self.contentView.yd_x = x
        self.updateConstraints()
        self.layoutIfNeeded()
    }
    
    func onDeleteBtnClicked(_ sender: UIButton) -> Void {
        guard let delegate = self.delegate as? PatuListTableViewCellDelegate else { return }
        
        delegate.patuListTableViewCell(self, deleteBtnClicked: sender)
    }
    
}
