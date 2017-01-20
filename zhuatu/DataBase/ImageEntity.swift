//
//  ImageEntity.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

class ImageEntity: Object {
    
    dynamic var name: String = ""
    dynamic var userName: String = ""
    dynamic var userId: String = ""
    dynamic var userHeaderImageUrl: String = ""
    dynamic var questionId: String = ""
    dynamic var answerId: String = ""
    
    let owners = LinkingObjects(fromType: PatuEntity.self, property: "imageList")
    
    var filePath: String {
        return "\(ImageDownloader.shareInstance.filePath!)\(self.name)"
    }
    
    var headerImagePath: String {
        return "\(ImageDownloader.shareInstance.filePath!)\(self.userHeaderImageUrl.md5()).jpg"
    }
    
    var questionUrl: String {
        return "https://www.zhihu.com/question/\(questionId)"
    }
    
    var answerUrl: String {
        return "https://www.zhihu.com/question/\(questionId)/answer/\(answerId)?" 
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["filePath"]
    }
}
