//
//  KZPostEntity.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/24.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import RealmSwift

/*
 count(number)，本次获取文章数量（一般为10，也可能小于10）
 posts(array)，文章信息列表，字段如下：
 date(string)，发表日期（yyyy-mm-dd）
 name(string)，文章名称（yesterday, recent, archive）
 pic(string)，抬头图url
 publishtime(number)，发表时间戳
 count(number)，文章包含答案数量
 excerpt(string)，摘要文字
 */

class KZPostEntity: Object {
    
    dynamic var id: String = ""
    dynamic var date: String = ""
    dynamic var name: String = ""
    dynamic var pic: String = ""
    dynamic var publishtime: Int64 = 0
    dynamic var count: Int = 0
    dynamic var excerpt: String = ""
    dynamic var isReaded: Bool = false
    let anwserList: List<KZAnswerEntity> = List<KZAnswerEntity>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var cnName: String {
        if name == "archive" {
            return "历史精华"
        } else if name == "yesterday" {
            return "昨日最新"
        } else {
            return "近日热门"
        }
    }
    
    var title: String {
        return cnName + "  " + date
    }
    
    
    func param(from json: JSON) -> KZPostEntity {
        id = json["id"].stringValue
        date = json["date"].stringValue
        name = json["name"].stringValue
        pic = json["pic"].stringValue
        publishtime = json["publishtime"].int64Value
        count = json["count"].intValue
        excerpt = json["excerpt"].stringValue
        
        return self
    }
}
