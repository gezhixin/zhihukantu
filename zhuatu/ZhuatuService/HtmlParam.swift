//
//  HtmlParam.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/10.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

struct AnswerItem {
    var userName: String
    var userHeaderIamgeUrl: String
    var userId: String
    var qid: String
    var answerId: String
    var imageUrls: [String]
}

class HtmlParam: NSObject {
    
    class func getHeaderTitle(_ html: String) -> String? {
    
        let doc = try? HTMLDocument(htmlString: html)
            
        guard let titleNode = doc?.head?.child(ofTag: "title") else { return nil }
            
       return titleNode.textContent as String?
       
        
    }
    
    class func getAnswerItemsFromHtml(_ html: String) -> [AnswerItem] {
        
        let doc = try? HTMLDocument(htmlString: html)
        
        var answerNodes: [HTMLNode] = []
        if let body = doc?.rootNode {
            self.getAnswerDivs(body, ansowerDivs: &answerNodes)
        }
        
        var answerItems: [AnswerItem] = []
        for node in answerNodes {
            let answerItem = self.paramAanswerItemFromNode(node)
            answerItems.append(answerItem)
        }
        
        return answerItems
    }
    
    class func paramAanswerItemFromNode(_ node: HTMLNode) -> AnswerItem {
        var name = ""
        var headerImageUrl = ""
        var userId = ""
        var images: [String] = []
        var qid: String = ""
        var answerId: String = ""
        
        if let linkHref = node.child(ofTag: "link")?.attribute(forName: "href") {
            if linkHref.contains("/question/") && linkHref.contains("/answer/") {
                let strArr = linkHref.components(separatedBy: "/")
                if strArr.count == 5 {
                    qid = strArr[2]
                    answerId = strArr[4]
                }
            }
        }
        
        var header: HTMLNode? = nil
        self.getAnswerHeaderNode(node, header: &header)
        
        if let header = header {
            self.paramAnswerHeaderFromNode(header, name: &name, headerImageUrl: &headerImageUrl, userId: &userId)
        }
        
        self.getImagesFromNode(node, images: &images)
        
        return AnswerItem(userName: name, userHeaderIamgeUrl: headerImageUrl, userId: userId, qid: qid, answerId: answerId, imageUrls: images)
    }
    
    class func getAnswerHeaderNode(_ root: HTMLNode, header: inout HTMLNode?)  {
        if root.attribute(forName: "class") == "zm-item-answer-author-info" {
            header = root
        } else  {
            for node in root.children {
                if node as? HTMLNode == nil {
                    continue
                }
               getAnswerHeaderNode((node as? HTMLNode)!, header: &header)
            }
        }
    }
    
    class func paramAnswerHeaderFromNode(_ node: HTMLNode, name: inout String, headerImageUrl: inout String, userId: inout String) {
        if let purl = node.attribute(forName: "href") {
            if purl.contains("/people/") {
                let strArray = purl.components(separatedBy: "/")
                if strArray.count == 3 {
                    userId = strArray[2]
                }
                if var hurl = node.child(ofTag: "img")?.attribute(forName: "src") {
                    if let range = hurl.range(of: "_s.") {
                         hurl.replaceSubrange(range, with: "_b.")
                    }
                    headerImageUrl = hurl
                }
                
                if let n = node.textContent {
                    name = n as String
                }
            }
        } else if node.children.count > 0 {
            for node in node.children {
                if node as? HTMLNode == nil {
                    continue
                }
                paramAnswerHeaderFromNode((node as? HTMLNode)!, name: &name, headerImageUrl: &headerImageUrl, userId: &userId)
            }
        }
    }
    
    
    class func getImagesFromNode(_ node: HTMLNode, images: inout [String]) {
        if node.children.count > 0 {
            for node in node.children {
                getImagesFromNode(node as! HTMLNode, images: &images)
            }
        } else {
            if node.tagName == "img" {
                if let imageUrl = node.attribute(forName: "src") {
                    if imageUrl.contains("_b.") || imageUrl.contains("_l.") {
                        images.append(imageUrl)
                    }
                }
            }
        }
    }
    
    class func getAnswerDivs(_ node: HTMLNode, ansowerDivs:inout [HTMLNode]) {
        if let linkHref = node.child(ofTag: "link")?.attribute(forName: "href") {
            if linkHref.contains("/question/") && linkHref.contains("/answer/") {
                ansowerDivs.append(node)
            }
        } else {
            if node.children.count > 0 {
                for node in node.children {
                    getAnswerDivs(node as! HTMLNode, ansowerDivs: &ansowerDivs)
                }
            }
        }
    }
}
