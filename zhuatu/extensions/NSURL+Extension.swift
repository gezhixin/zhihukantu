//
//  NSURL+Extension.swift
//  ydzs
//
//  Created by gezhixin on 16/5/5.
//  Copyright © 2016年 葛枝鑫. All rights reserved.
//

import UIKit

extension  URL {
    
    func getQueryParam() -> [String: String] {
        var dic:[String : String] = [:]
        if let queryStr = self.query {
            let queryKVS = queryStr.components(separatedBy: "&")
            for kv in queryKVS {
                let kvarr = kv.components(separatedBy: "=")
                if kvarr.count == 2 {
                    dic[kvarr[0]] = kvarr[1]
                }
            }
        }
        return dic
    }
}
