//
//  PatuEntity.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

class PatuEntity: Object {
    
    dynamic var questionId: String = ""
    dynamic var title: String = ""
    dynamic var subTitle: String = ""
    dynamic var titleImageName: String = ""
    dynamic var lastOffset: Int = 0
    dynamic var url: String = ""
    dynamic var createDate: Date = Date()
    dynamic var isQuestion: Bool = true
    dynamic var isCollections: Bool = false
    let imageList = List<ImageEntity>()
    
    var titleImageFilePath: String {
        if let image = imageList.first {
            return image.filePath
        }
        return "\(ImageDownloader.shareInstance.filePath!)\(self.titleImageName)"
    }
    
    var iamgeCountDesc: String {
        return "共 \(imageList.count) 张"
    }
    
    var isGuid: Bool {
        return questionId == "【使用指南】".md5()
    }
    
    override static func primaryKey() -> String? {
        return "questionId"
    }
}
