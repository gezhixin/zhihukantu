//
//  KZNetwork.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/25.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class KZNetwork: NSObject {
    var postListRequest: Request?
    var answerListRequest: Request?
    
    func getPostList(with time: Int64, success:(() -> Void)?, failed:((_ errorCode: Int, _ errorMesg: String) -> Void)?) -> Void {
        
        let url = "http://api.kanzhihu.com/getposts/\(time)"
        
        postListRequest?.cancel()
        postListRequest = request(url, method: .get, parameters: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let result):
                DispatchQueue.global().async {
                    let resDic = JSON(result)
                    if resDic["error"] == "" {
                        
                        var realmNil: Realm?
                        do {
                            realmNil = try Realm()
                        } catch {}
                        
                        guard let realm = realmNil else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                                failed?(886, "数据库挂了！")
                            })
                            return
                        }
                        
                        let postDicList = resDic["posts"].arrayValue
                        for postDic in postDicList {
                            
                            if realm.object(ofType: KZPostEntity.self, forPrimaryKey: postDic["id"].stringValue) != nil {
                                continue
                            }
                            
                            let postEntity = KZPostEntity().param(from: postDic)
                            do {
                                try realm.write {
                                    realm.add(postEntity, update: true)
                                }
                            } catch {}
                           
                        }
                        DispatchQueue.global().async {
                            if let time = postDicList.last?["publishtime"].string {
                                do {
                                    let realm = try Realm()
                                    let list = realm.objects(KZPostEntity.self).filter("publishtime < \(time)")
                                    for p in list {
                                        try realm.write {
                                            realm.delete(p.anwserList)
                                            realm.delete(p)
                                        }
                                    }
                                } catch {}
                            }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                                success?()
                            })
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                            failed?(886, resDic["error"].stringValue)
                        })
                    }
                }
                break
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    failed?(110, "网络错误，难道服务器挂了😱")
                })
                break
            }
        })
    }
    
    func getAnswerList(with post: KZPostEntity,success:(() -> Void)?, failed:((_ errorCode: Int, _ errorMesg: String) -> Void)?) {
        let url = "http://api.kanzhihu.com/getpostanswers/" + post.date.replacingOccurrences(of: "-", with: "") + "/" + post.name
        let postId = post.id
        request(url, method: .get, parameters: nil).responseJSON { (response) in
            
            switch response.result {
            case .success(let result):
                DispatchQueue.global().async {
                    
                    var realmNil: Realm?
                    var postNil: KZPostEntity?
                    do {
                        realmNil = try Realm()
                        postNil = realmNil?.object(ofType: KZPostEntity.self, forPrimaryKey: postId)
                    } catch {}
                    
                    guard let realm = realmNil,  let post = postNil else {
                        DispatchQueue.main.async {
                            failed?(886, "数据库有问呀")
                        }
                        return
                    }
                    
                    let resDic = JSON(result)
                    if resDic["error"] == "" {
                        let answerDicList = resDic["answers"].arrayValue
                        for answerDic in answerDicList {
                            let anserEntity = KZAnswerEntity().param(from: answerDic)
                            do {
                                try realm.write {
                                    realm.add(anserEntity, update: true)
                                    if nil == post.anwserList.index(of: anserEntity) {
                                        post.anwserList.append(anserEntity)
                                    }
                                }
                            } catch {}
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                            success?()
                        })
                    } else {
                        DispatchQueue.main.async {
                            failed?(886, resDic["error"].stringValue)
                        }
                    }
                }
                break
            case .failure(_):
                failed?(110, "网络错误，难道服务器挂了😱")
                break
            }
        }
    }
    
    func checkNew(with time: Int64, success:(() -> Void)?) {
        let url = "http://api.kanzhihu.com/checknew/\(time)"
        request(url, method: .get, parameters: nil).responseJSON { (response) in
            if let data = response.result.value {
                if JSON(data)["result"].boolValue {
                    success?()
                }
            }
        }
    }
}
