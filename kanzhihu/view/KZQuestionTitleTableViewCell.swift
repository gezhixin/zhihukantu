//
//  KZQuestionTitleTableViewCell.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/25.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class KZQuestionTitleTableViewCell: UITableViewCell {
    
    static let identifier = "KZQuestionTitleTableViewCell"
    static let cellHeight = CGFloat(36)
    
    var titleLabel: UILabel!
    private var _sectionData: ANSectionData!
    
    var sectionData: ANSectionData {
        set {
            _sectionData = newValue
            titleLabel.text = _sectionData.title
        }
        get {
            return _sectionData
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 2, width: yd_width - 30, height: yd_height)
    }
    
    override init(style: UITableViewCellStyle = .default, reuseIdentifier: String? = KZAnswerTableViewCell.identifier) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor(hex: 0x333333)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.titleLabel.textColor = !highlighted ? UIColor(hex: 0x333333) : UIColor(hex: 0x333333, alpha: 0.5)
    }
    
}
