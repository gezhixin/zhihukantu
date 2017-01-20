//
//  ImagePeekPreViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/13.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit
import Alamofire

class ImagePeekPreViewController: UIViewController {
    
    var headerIamgeView: UIImageView!
    var userNameLabel: UILabel!
    var bigImageView: UIImageView!
    
    var viewDidLoaded: Bool = false
    
    weak var backViewContoller: UIViewController?
    
    lazy var _imageEntity: ImageEntity = ImageEntity()
    var imageEntity: ImageEntity {
        set {
            _imageEntity = newValue
            if viewDidLoaded {
                updateView()
            }
        } get {
            return _imageEntity
        }
    }
    
    convenience init(imageEntity: ImageEntity) {
        self.init()
        self.imageEntity = imageEntity
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        
        headerIamgeView = UIImageView(frame: CGRect(x: 15, y: 15, width: 40, height: 40))
        headerIamgeView.layer.masksToBounds = true
        headerIamgeView.layer.cornerRadius = 4
        view.addSubview(headerIamgeView)
        
        userNameLabel = UILabel(frame: CGRect(x:65, y: 15, width: view.yd_width - 130, height: 40))
        userNameLabel.textColor = UIColor(hex: 0x333333)
        userNameLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(userNameLabel)
        
        let biWidth = view.yd_width - 30
        bigImageView = UIImageView(frame: CGRect(x: 15, y: 75, width: biWidth, height: 60))
        view.addSubview(bigImageView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerIamgeView.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
        userNameLabel.frame = CGRect(x:65, y: 15, width: view.yd_width - 130, height: 40)
        bigImageView.frame = CGRect(x: 15, y: 75, width: view.yd_width - 30, height: 60)
        
        if let image = bigImageView.image {
            bigImageView.yd_height = image.size.height / image.size.width * bigImageView.yd_width
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateView()  {
        let headerImage = UIImage(contentsOfFile: imageEntity.headerImagePath)
        if headerImage == nil {
            request(_imageEntity.userHeaderImageUrl).responseData(completionHandler: { (response) in
                if let data = response.result.value {
                    NSData(data: data).write(toFile: self.imageEntity.headerImagePath, atomically: true)
                    self.headerIamgeView.image = UIImage(data: data)
                }
            })
        }
        
        headerIamgeView.image = headerImage
        userNameLabel.text = imageEntity.userName
        bigImageView.image = UIImage(contentsOfFile: imageEntity.filePath)
        if let image = bigImageView.image {
            bigImageView.yd_height = image.size.height / image.size.width * bigImageView.yd_width
        }
    }
    
    @available(iOS 9.0, *)
    override var previewActionItems : [UIPreviewActionItem] {
        let seeAnswerAction = UIPreviewAction(title: "查看答案", style: UIPreviewActionStyle.default, handler: {
                                                (previewAction,viewController) in
            DispatchQueue.main.async(execute: {
                if let peekVC = viewController as? ImagePeekPreViewController {
                    _ = ZhuatuService.openZhihuQustionOrAnswer(with: peekVC.imageEntity.questionId, aid: peekVC.imageEntity.answerId)
                }
            })
        })
        
        let goUserPageAction = UIPreviewAction(title: "个人主页", style: .default) { (perviewAction, viewController) in
            DispatchQueue.main.async(execute: { 
                if let peekVC = viewController as? ImagePeekPreViewController {
                    _ = ZhuatuService.openPeopleHomePage(with: peekVC.imageEntity.userId) 
                }
            })
        }
        
        let cancelAction = UIPreviewAction(title: "分享", style: .default) { (perviewAction, viewController) in
            DispatchQueue.main.async(execute: { 
                if let peekVC = viewController as? ImagePeekPreViewController {
                    if let bvc = peekVC.backViewContoller as? PTImageListViewController {
                        if let image = UIImage(contentsOfFile: peekVC.imageEntity.filePath) {
                            bvc.preShareImages.append(image)
                            bvc.shareWithActiveVC()
                        }
                    }
                }
            })
        }
       
        if !imageEntity.questionId.isEmpty && !imageEntity.userId.isEmpty {
            return [seeAnswerAction, goUserPageAction, cancelAction]
        } else if !imageEntity.userId.isEmpty {
            return [goUserPageAction, cancelAction]
        } else if !imageEntity.questionId.isEmpty {
            return [seeAnswerAction, cancelAction]
        }else {
            return [cancelAction]
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        
        if didFinishSavingWithError != nil {
          _ = ZXTopPromptView.showWarning(tips: "保存失败！\n☹️")
            return
        }
        
        _ = ZXTopPromptView.showSuccess(tips: "保存成功！\n😀")
    }
}
