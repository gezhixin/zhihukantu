//
//  KZAnswerTableViewCell.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/24.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class KZAnswerTableViewCell: UITableViewCell {
    
    static let identifier = "KZAnswerTableViewCell"
    static let cellHeight = CGFloat(100)
    
    var headerImageView: UIImageView!
    var nameLabel: UILabel!
    var zanIcon: UIImageView!
    var zanCountLabel: UILabel!
    var detailLabel: UILabel!
    var bottomLine: UIView!
    var headerBtn: UIButton!
    
    var blkHeaderClicked:((_ cell: KZAnswerTableViewCell) -> Void)?
    
    private var _answerEntity: KZAnswerEntity = KZAnswerEntity()
    
    //MARK: - Init
    override init(style: UITableViewCellStyle = .default, reuseIdentifier: String? = KZAnswerTableViewCell.identifier) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        headerImageView = UIImageView()
        headerImageView.image = UIImage(named: "default_header.jpg")
        headerImageView.backgroundColor = UIColor(hex: 0xeeeeee)
        headerImageView.layer.masksToBounds = true
        headerImageView.layer.cornerRadius = 4
        contentView.addSubview(headerImageView)
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(nameLabel)
        
        zanIcon = UIImageView(image:#imageLiteral(resourceName: "icon_zan"))
        contentView.addSubview(zanIcon)
        
        zanCountLabel = UILabel()
        zanCountLabel.textColor = UIColor(hex: 0x666666)
        zanCountLabel.textAlignment = .right
        zanCountLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(zanCountLabel)
        
        detailLabel = UILabel()
        detailLabel.textColor = UIColor(hex: 0x666666)
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.numberOfLines = 0
        contentView.addSubview(detailLabel)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hex: 0xeeeeee)
        contentView.addSubview(bottomLine)
        
        headerBtn = UIButton(type: .custom)
        headerBtn.addTarget(self, action: #selector(self.onHeadImageClicked(_:)), for: .touchUpInside)
        contentView.addSubview(headerBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = selected ? UIColor(hex: 0xeeeeee) : UIColor.white
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = KZAnswerTableViewCell.cellHeight
        
        headerImageView.frame = CGRect(x: 15, y: 10, width: h - 20, height: h - 20)
        headerBtn.frame = headerImageView.frame
        nameLabel.frame = CGRect(x: headerImageView.yd_right + 8, y: 11, width: 200, height: 16)
        
        zanIcon.frame = CGRect(x: contentView.yd_width - 31, y: 11, width: 16, height: 16)
        zanCountLabel.frame = CGRect(x: 0, y: 12, width: 150, height: 16)
        zanCountLabel.yd_right = zanIcon.yd_x - 4
        
        
        detailLabel.frame = CGRect(x: nameLabel.yd_x, y: nameLabel.yd_bottom + 4, width: contentView.yd_width - nameLabel.yd_x - 19, height: contentView.yd_height - nameLabel.yd_bottom - 15)
        
        bottomLine.frame = CGRect(x: 15, y: h - 0.5, width: contentView.yd_width - 15, height: 0.5)
    }
    
    func updateView() -> Void {
        headerImageView.sd_setImage(with: URL(string: _answerEntity.avatar), placeholderImage: UIImage(named: "default_header.jpg"))
        nameLabel.text = _answerEntity.authorname
        zanCountLabel.text = _answerEntity.vote
        detailLabel.text = _answerEntity.summary
        layoutSubviews()
    }
    
    func onHeadImageClicked(_ sender: UIButton) -> Void {
        self.blkHeaderClicked?(self)
    }
    
    //MARK: - Setter Getter
    var anserEntity: KZAnswerEntity {
        set {
            if _answerEntity == newValue {
                return
            }
            _answerEntity = newValue
            updateView()
        }
        get {
            return _answerEntity
        }
    }

}
