//
//  ImageDownloader.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

enum TaskState {
    case ready
    case runing
    case pause
    case done
}

class ImageDownloadTask {
    var qid: String
    var state: TaskState
    var url: String
    var answerItem: AnswerItem? = nil
    weak var request: Request? = nil
    
    init(qid: String, state: TaskState, url: String, answerItem: AnswerItem? = nil, request: Request? = nil) {
        self.qid = qid
        self.state = state
        self.url = url
        self.answerItem = answerItem
        self.request = request
    }
    
    func filePath() -> String {
        return "\(ImageDownloader.shareInstance.filePath!)\(self.iamgeName())"
    }
    
    func iamgeName() -> String {
        return "\(url.md5()).jpg"
    }
    
    func fileExistsAtPath() -> Bool {
        return FileManager.default.fileExists(atPath: self.filePath())
    }
}

class ImageDownloader: NSObject {
    
    var blkComplated:((Void) -> Void)?
    
    var tastQueue: [ImageDownloadTask] = []
    
    var filePath: String! = "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask,true)[0])/Images/"
    
    class var shareInstance: ImageDownloader {
        struct Static {
           static let instance = ImageDownloader()
        }
        return Static.instance
    }
    
    deinit {
        cancelAll()
    }
    
    func appendTaskFromAnswerItem(_ item: AnswerItem, qid: String) {
        for imageUrl in item.imageUrls {
            let task = ImageDownloadTask(qid: qid, state: .ready, url: imageUrl, answerItem: item)
            if task.fileExistsAtPath() {
                continue
            }
            self.tastQueue.append(task)
        }
    }
    
    func start() -> Bool {
        
        guard var tast = tastQueue.first else { return false }
        
        if tast.state == .runing {
            return true
        }
        
        self.satartTask(&tast)
        
        return true
    }
    
    func  cancelAll() -> Void {
        for task in tastQueue {
            task.request?.cancel()
        }
        self.tastQueue.removeAll()
        self.blkComplated = nil
    }
    
    func satartTask(_ task: inout ImageDownloadTask) -> Void {
        if task.state == .ready {
            task.state = .runing
            
            if FileManager.default.fileExists(atPath: task.filePath()) {
                if self.tastQueue.count > 0 {
                    self.tastQueue.remove(at: 0)
                }
                
                if var tastNext = self.tastQueue.first {
                    self.satartTask(&tastNext)
                } else {
                    self.blkComplated?()
                }
                return
            }
        }
            weak var wTask = task
            task.request = request(task.url).responseData{ (response) in
                guard let sTask = wTask else { return }
                sTask.state = .done
                DispatchQueue.global().async(execute: {
                    let filePath = sTask.filePath()
                    let imageName = sTask.iamgeName()
                    if let data = response.result.value {
                        NSData(data: data).write(toFile: filePath, atomically: true)
                        let realm = try! Realm()
                        if let pt = realm.objects(PatuEntity.self).filter("questionId = %@", sTask.qid).first {
                            if pt.imageList.filter("name = %@", imageName).count == 0 {
                                let imageEntity = ImageEntity()
                                imageEntity.name = imageName
                                if let answerItem = sTask.answerItem {
                                    imageEntity.userName = answerItem.userName
                                    imageEntity.userHeaderImageUrl = answerItem.userHeaderIamgeUrl
                                    imageEntity.userId = answerItem.userId
                                    imageEntity.questionId = answerItem.qid
                                    imageEntity.answerId = answerItem.answerId
                                }
                                do {
                                    try realm.write({
                                        realm.add(imageEntity, update: true)
                                        pt.imageList.append(imageEntity)
                                    })
                                } catch { }
                            }
                        }
                    }
                })
                
                if self.tastQueue.count > 0 {
                    self.tastQueue.remove(at: 0)
                }
                
                if var tastNext = self.tastQueue.first {
                    self.satartTask(&tastNext)
                } else {
                    self.blkComplated?()
                }
            }
    }
}

