//
//  CollectionOptionTableViewCell.swift
//  zhuatu
//
//  Created by gezhixin on 2017/1/19.
//  Copyright © 2017年 gezhixin. All rights reserved.
//

import UIKit

class CollectionOptionTableViewCell: UITableViewCell {

    var titleImageView: UIImageView!
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var addIcon: UIImageView!
    
    var _is4AddColloction = false
    
    var is4AddColloction: Bool {
        set {
            _is4AddColloction = newValue
            addIcon.isHidden = !_is4AddColloction
            if _is4AddColloction {
                titleLabel.center.y = titleImageView.center.y
            } else {
                titleImageView.yd_y = 15
            }
        } get {
            return _is4AddColloction
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? UIColor(hex: 0xf0f0f0) : UIColor.white
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        let width = UIScreen.main.bounds.size.width
        self.frame = CGRect(x: 0, y: 0, width: width, height: 60)
        
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor(hex: 0xeeeeee)
        
        
        titleImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        titleImageView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        titleImageView.layer.masksToBounds = true
        titleImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(titleImageView)
        
        
        titleLabel = UILabel(frame: CGRect(x: titleImageView.yd_right + 10, y: 15, width: width - 80, height: 20))
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(hex: 0x333333)
        
        subTitleLabel = UILabel(frame: CGRect(x: titleImageView.yd_right + 10, y: 35, width: width - 80, height: 15))
        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.textColor = UIColor(hex: 0x666666)
        
        addIcon = UIImageView()
        addIcon.isHidden = true
        addIcon.backgroundColor = UIColor.clear
        addIcon.image = #imageLiteral(resourceName: "icon_add")
        addIcon.frame.size = addIcon.image!.size
        addIcon.center = titleImageView.center
        self.contentView.addSubview(addIcon)
        
        let line = UIView(frame: CGRect(x: titleLabel.yd_x, y: 59.5, width: self.yd_width - titleLabel.yd_x, height: 0.5))
        line.backgroundColor = UIColor(hex: 0xeeeeee, alpha: 1)
        self.contentView.addSubview(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
