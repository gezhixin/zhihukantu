//
//  KZAnswerEntity.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/25.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import RealmSwift

/*
 title(string)，文章id
 time(datetime)，发表时间
 summary(string)，答案摘要
 questionid(string)，问题id，8位数字
 answerid(string)，答案id，8~9位数字
 authorname(string)，答主名称
 authorhash(string)，答主hash
 avatar(string)，答主头像url
 vote(number)，赞同票数
 */

class KZAnswerEntity: Object {

    dynamic var answerid: String = ""
    dynamic var title: String = ""
    dynamic var time: String = ""
    dynamic var summary: String = ""
    dynamic var questionid: String = ""
    dynamic var authorname: String = ""
    dynamic var authorhash: String = ""
    dynamic var avatar: String = ""
    dynamic var vote: String = ""
    
    override static func primaryKey() -> String? {
        return "answerid"
    }
    
    func param(from json: JSON) -> KZAnswerEntity {
        
        title = json["title"].stringValue
        time = json["time"].stringValue
        summary = json["summary"].stringValue
        questionid = json["questionid"].stringValue
        answerid = json["answerid"].stringValue
        authorname = json["authorname"].stringValue
        authorhash = json["authorhash"].stringValue
        avatar = json["avatar"].stringValue
        vote = json["vote"].stringValue
        
        return self
    }
}
