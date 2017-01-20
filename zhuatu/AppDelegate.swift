//
//  AppDelegate.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/9.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: RootViewController = RootViewController()
    let enableKanzhihu = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc1 = ViewController()
        if enableKanzhihu {
            let vc2 = KZRootContentViewController()
             rootViewController.contentViewControllers = [vc1, vc2]
        } else {
            let vc3 = ViewController(isCollections: true)
            rootViewController.contentViewControllers = [vc1, vc3]
        }
        self.window?.rootViewController = rootViewController
        self.window!.makeKeyAndVisible()
        
        do {
            if !FileManager.default.fileExists(atPath: ImageDownloader.shareInstance.filePath!) {
                try FileManager.default.createDirectory(atPath: ImageDownloader.shareInstance.filePath!, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {}
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        DispatchQueue.global().async {
            if let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.allLibrariesDirectory,FileManager.SearchPathDomainMask.userDomainMask,true).first {
                let fileBaseFolder = "\(filePath)/Caches/xin.com.zhihukantu/fsCachedData/"
                if let files = FileManager.default.subpaths(atPath: fileBaseFolder) {
                    for file in files {
                        if FileManager.default.fileExists(atPath: "\(fileBaseFolder)\(file)") {
                            do {
                                try FileManager.default.removeItem(atPath: "\(fileBaseFolder)\(file)")
                            } catch {
                                
                            }
                        }
                    }
                }
            }
            SDImageCache.shared().cleanDisk()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        chechNewPost()
        openPasteZhihuUrl()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    //MARK: - 
    func chechNewPost()  {
        rootViewController.checkNewPost()
    }
    
    var lastPast: String = ""
    func openPasteZhihuUrl() {
        
        guard  let paste = UIPasteboard.general.string else {
            return
        }
        
        if lastPast == paste {
            return
        }
        
        lastPast = paste
        
        if paste.contains("www.zhihu.com") && paste.contains("/question/") {
            let url = NSURL(string: paste)
            if let path = url?.path {
                if path.contains("/question/") {
                    let startIndex = "/question/".endIndex
                    let realWantPath = path.substring(from: startIndex)
                    let strArr = realWantPath.components(separatedBy: "/")
                    if strArr.count >= 1 {
                        let qid = strArr[0]
                        var answerId: String? = nil
                        if strArr.count == 3 {
                            answerId = strArr[2]
                        }
                        let msg = answerId != nil ? "有一个来至知乎的问题，需要查看它的图片吗？" : "有一个来至知乎的答案，需要查看它的图片吗？"
                        let alert = UIAlertController(title: "提示",
                                                      message: msg,
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "看图",
                                                      style: UIAlertActionStyle.default,
                                                      handler: { [unowned self] Void in
                                                        let rootViewController = self.rootViewController
                                                        
                                                        var delayTime = Int(0)
                                                        
                                                        if let vc = rootViewController.viewControllers.last as? KZListViewController {
                                                            vc.onCancelBtnClicked(sender: nil)
                                                            delayTime = 400
                                                        } else if let vc = rootViewController.viewControllers.last as? PTImageListViewController {
                                                            vc.onLiftBarClicked(nil)
                                                            delayTime = 400
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline:  .now() + .milliseconds(delayTime), execute: {
                                                            let rect = CGRect(x: rootViewController.contentView.yd_width, y: 0, width: 0, height: rootViewController.contentView.yd_height)
                                                            rootViewController.contentView.scrollRectToVisible(rect, animated: false)
                                                            if let imvc = rootViewController.contentViewControllers.first as? ViewController {
                                                                if nil != answerId {
                                                                    var httpsUrl = paste
                                                                    if !paste.contains("https:") {
                                                                        httpsUrl = paste.insert("s", ind: 4)
                                                                    }
                                                                    imvc.addQuestionOrOthrer(with: "", url: httpsUrl)
                                                                } else {
                                                                    imvc.addQuestionOrOthrer(with: qid)
                                                                }
                                                            }
                                                        })
                                                        
                            }))
                        alert.addAction(UIAlertAction(title: "忽略",
                                                      style: UIAlertActionStyle.cancel,
                                                      handler: nil))
                        rootViewController.present(alert, animated: true, completion: {
                        })
                    }
                }
            }
        }
    }
}

