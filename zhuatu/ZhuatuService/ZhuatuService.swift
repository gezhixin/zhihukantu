//
//  ZhuatuService.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import Alamofire

class ZhuatuService: NSObject {
    
    var qid: String = ""
    let pageSize: Int = 5
    var lastOffset: Int = 0
    var finished: Bool = false
    
    var isRuning: Bool = false
    
    var isCancelAll = false
    
    var htmlRequest: Request?
    
    var blkComplated:((Bool) -> Void)?
    
    let iamgeDownloader = ImageDownloader()
    
    class func openZhihuQustionOrAnswer(with qId: String, aid: String? = nil) -> Bool {
        
        var urlInApp = "zhihu://questions/\(qId)"
        if let relAid = aid {
            urlInApp = "zhihu://questions/\(qId)/answers/\(relAid)"
        }
        let reUrl = URL(string: urlInApp)
        return UIApplication.shared.openURL(reUrl!)
    }
    
    class func openPeopleHomePage(with id: String) -> Bool {
        let url = "zhihu://people/\(id)"
        return UIApplication.shared.openURL(URL(string: url)!)
    }
    
    class func getTitleFromHtml(_ url: String, complated:((_ title: String?, _ html: String?) -> Void)?) -> Void {
        ZhihuNetwork.getHtmlStrFromUrl(url) { (htmlStr) in
            if let htmlStr = htmlStr {
                DispatchQueue.global().async {
                    let title = HtmlParam.getHeaderTitle(htmlStr)
                    DispatchQueue.main.async(execute: { 
                        complated?(title, htmlStr)
                    })
                }
            } else {
                complated?(nil, nil)
            }
        }
    }
    
    func getImageFromQuestionWitId(_ qid: String, complated:((Bool) -> Void)?) -> Void {
        
        self.qid = qid
        self.blkComplated = complated
        
        weak var weakSelf = self
        self.isRuning = true
        self.iamgeDownloader.blkComplated = {
            (Void) in
            guard let strongSelf = weakSelf else { return }
            strongSelf.ended()
        }
        
        self.fetchImages()
    }
    
    func ended() -> Void {
        DispatchQueue.main.async { 
            self.isRuning = false
            self.blkComplated?(self.finished)
        }
    }
    
    func loadMore() -> Void {
        if self.finished == false && self.isRuning == false {
            self.isRuning = true
            weak var weakSelf = self
            self.iamgeDownloader.blkComplated = {
                (Void) in
                guard let strongSelf = weakSelf else { return }
                strongSelf.ended()
            }
            lastOffset += pageSize
            self.fetchImages()
        }
    }
    
    func fetchImages() -> Void {
        
        if self.isCancelAll {
            return
        }
        
        htmlRequest = ZhihuNetwork.downloadImageFrom(qid, pageSize: pageSize, offset: lastOffset) { (nodes) in
            DispatchQueue.global().async {
                if let nodes = nodes {
                    if nodes.count == 0 {
                        self.finished = true
                    }
                    for node in nodes {
                        let answerItems = HtmlParam.getAnswerItemsFromHtml(node)
                        for answerItem in answerItems {
                            self.iamgeDownloader.appendTaskFromAnswerItem(answerItem, qid: self.qid)
                        }
                    }
                    
                    if self.iamgeDownloader.tastQueue.count < 20 {
                        self.lastOffset += self.pageSize
                        self.fetchImages()
                    } else {
                        if (self.iamgeDownloader.tastQueue.count > 0) {
                            _ = self.iamgeDownloader.start()
                        } else {
                            self.ended()
                        }
                    }
                } else {
                    self.finished = true
                    if (self.iamgeDownloader.tastQueue.count > 0) {
                       _ = self.iamgeDownloader.start()
                    } else {
                        self.ended()
                    }
                }
            }
        }
    }
    
    func cancelAll() -> Void {
        self.htmlRequest?.cancel()
        self.iamgeDownloader.cancelAll()
        self.isCancelAll = true
        self.blkComplated = nil
    }
    
    func downLoadIamgesFromHtml(_ html: String, complated:((Bool) -> Void)?) -> Void {
        self.blkComplated = complated
        self.isRuning = true
        weak var weakSelf = self
        self.iamgeDownloader.blkComplated = {
            (Void) in
            guard let strongSelf = weakSelf else { return }
            strongSelf.ended()
        }
        
        DispatchQueue.global().async {
            let answers = HtmlParam.getAnswerItemsFromHtml(html)
            
            for answer in answers {
                self.iamgeDownloader.appendTaskFromAnswerItem(answer, qid: self.qid)
            }
            
            if !self.iamgeDownloader.start() {
                self.ended()
            }
        }
    }
}
