//
//  SmallImageCollectionViewCell.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class SmallImageCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var selectIcon: UIImageView?
    var selectedCover: UIView?
    
    
    var _isEditing: Bool = false
    
    var isEditing: Bool {
        set {
            _isSelected = newValue
            if newValue {
                if selectIcon == nil {
                    selectedCover = UIView()
                    selectedCover?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                    selectedCover?.frame = imageView.bounds
                    imageView.addSubview(selectedCover!)
                    
                    selectIcon = UIImageView()
                    selectIcon?.image = _isSelected ? UIImage(named: "icon_selected") : UIImage(named: "icon_deselected")
                    self.imageView.addSubview(selectIcon!)
                    selectIcon?.frame = CGRect(x: 0, y: 0, width: selectIcon!.image!.size.width, height: selectIcon!.image!.size.height)
                    selectIcon?.yd_y =  5
                    selectIcon?.yd_x = imageView.yd_width - selectIcon!.yd_width - 5
                    
                }
            } else {
                self.selectIcon?.removeFromSuperview()
                self.selectedCover?.removeFromSuperview()
                self.selectIcon = nil
                self.selectedCover = nil
            }
        } get {
            return _isEditing
        }
    }
    
    var _isSelected: Bool = false
    var isOnSelected: Bool {
        get {
            return _isSelected
        } set {
            _isSelected = newValue
            selectIcon?.image = _isSelected ? UIImage(named: "icon_selected") : UIImage(named: "icon_deselected")
            selectIcon?.frame = CGRect(x: 0, y: 0, width: selectIcon!.image!.size.width, height: selectIcon!.image!.size.height)
            selectIcon?.yd_y =  5
            selectIcon?.yd_x = imageView.yd_width - selectIcon!.yd_width - 5
           
            if _isSelected {
                selectedCover?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                selectedCover?.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 3, y: 4, width: yd_width - 6, height: yd_height - 8))
        contentView.addSubview(imageView)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
