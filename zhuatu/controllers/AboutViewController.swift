//
//  AboutViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/11.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController, UIScrollViewDelegate {
    
    var titleView: PTTitleView!
    var contentView: UIScrollView!
    var pages: Int = 0

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        
        contentView = UIScrollView(frame: CGRect(x: 0, y: 40, width: view.yd_width, height: view.yd_height - 40))
        contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.isPagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.bounces = false
        contentView.delegate = self
        view.addSubview(contentView)
        
        for i in 0 ..< 2 {
            if let page = self.pageView(at: i) {
                contentView.addSubview(page)
                page.yd_x = CGFloat(pages) * contentView.yd_width
                pages = pages + 1
            }
        }
        contentView.contentSize = CGSize(width: CGFloat(pages) * contentView.yd_width, height: contentView.yd_height)
        
        titleView = PTTitleView(with: "帮助(1/\(pages))")
        titleView.frame = CGRect(x: 0, y: 0, width: view.yd_width, height: 40)
        view.addSubview(titleView)
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        btn.addTarget(self, action: #selector(self.onCloseBtnClicked(sender:)), for: .touchUpInside)
        titleView.leftItem = btn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于"
    }
    
    func pageView(at index: Int) -> UIView? {
        
        guard let image = UIImage(named: "about_\(index + 1).PNG") else { return nil }
        
        let contentView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.yd_width, height: view.yd_height - 40))
        contentView.bounces = false
       
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: view.yd_width, height: view.yd_width * image.size.height / image.size.width)
        
        contentView.addSubview(imageView)
        contentView.contentSize = CGSize(width: contentView.yd_width, height: imageView.yd_height)
        return contentView
    }
    
    func onCloseBtnClicked(sender: UIButton) -> Void {
        self.nvc?.popViewController(animated: true, direction: .bottom)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        if scrollView.yd_width == 0 {
            return;
        }
        if Int(offsetX) % Int(scrollView.yd_width) == 0 {
            let index = offsetX / scrollView.yd_width
            let IntIndex = Int(index)
            titleView.title = "帮助(\(IntIndex + 1)/\(pages))"
        }
    }
}
