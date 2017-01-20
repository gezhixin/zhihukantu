//
//  ZhihuNetwork.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import Alamofire


class ZhihuNetwork: NSObject {
    
    class func downloadImageFrom(_ qid: String, pageSize: Int, offset: Int, complated:(([String]?) -> Void)?) -> Request {
        var header: [String: String] = [:]
        header["Contnt-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
        header["Cookie"] = ""
        
       return request("https://www.zhihu.com/node/QuestionAnswerListV2", method: HTTPMethod.post, parameters:  ["method":"next", "params":"{\"url_token\":\(qid),\"pagesize\":\(pageSize),\"offset\":\(offset)}"], encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            if response.data != nil {
//                let str = String(data: data, encoding: String.Encoding.utf8)
//                print("html: \(str)")
            }
            if let htmlDic = response.result.value as? Dictionary<String, Any> {
                if let nodes = htmlDic["msg"] as? [String] {
                    if (nodes.isEmpty) {
                        complated?(nil)
                    } else {
                        complated?(nodes)
                    }
                    
                } else {
                    complated?(nil)
                }
            } else {
                complated?(nil)
            }
        }
    }
    
    class func getHtmlStrFromUrl(_ url: String, complated:((_ htmlStr: String?) -> Void)?) {
        request(url).responseString { (response) in
            complated?(response.result.value)
        }
    }
    
    class func questionUrlWithId(_ qid: String) -> String {
        return "https://www.zhihu.com/question/\(qid)"
    }
}
