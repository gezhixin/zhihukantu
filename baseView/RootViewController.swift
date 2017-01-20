//
//  RootViewController.swift
//  zhuatu
//
//  Created by gezhixin on 16/9/22.
//  Copyright © 2016年 gezhixin. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIScrollViewDelegate {
    
    fileprivate var  _contentViewControllers: [BaseViewController] = []
    fileprivate var _viewControllers: [BaseViewController] = []
    
    var selectedIndex: Int = 0
    
    var insert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    var contentViewControllers: [BaseViewController] {
        get {
            return _contentViewControllers
        } set {
            for vc in _contentViewControllers {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
            _contentViewControllers = newValue
            if  !isViewLoaded {
                return
            }
            
            naviBar.viewControllers = newValue
            
            for (index, vc) in _contentViewControllers.enumerated() {
                _ = vc.view
                vc.naviBar = naviBar
                vc.view.frame = CGRect(x: contentView.yd_width * CGFloat(index) + insert.left, y: 0 + insert.top, width: contentView.yd_width - insert.left - insert.right, height: contentView.yd_height - insert.top - insert.bottom)
                vc.view.layer.masksToBounds = true
                vc.view.layer.cornerRadius = 8
                contentView.addSubview(vc.view)
                addChildViewController(vc)
            }
            
            _contentViewControllers.first?.setNaviBarItem()
            
            contentView.contentSize = CGSize(width: contentView.yd_width * CGFloat(_contentViewControllers.count) + 0.1, height: contentView.yd_height)
        }
    }
    
    var viewControllers: [BaseViewController] {
        return _viewControllers
    }
    
    
    var contentView: UIScrollView!
    var naviBar: ZXNaviBar!
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(hex: 0x101010)
        
        naviBar = ZXNaviBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.addSubview(naviBar)
        naviBar.blkBarItemClicked = {
            (index) in
            if index == self.selectedIndex {
                if let vc = self.contentViewControllers[index] as? ViewController {
                    vc.startIndex = 0
                } else if let vc = self.contentViewControllers[index] as? KZRootContentViewController {
                    vc.startIndex = 0
                }
            } else {
                let rect = CGRect(x: CGFloat(index) * self.contentView.yd_width, y: 0, width: self.contentView.yd_width, height: self.contentView.yd_height)
                self.contentView.scrollRectToVisible(rect, animated: true)
            }
        }
        
        contentView = UIScrollView(frame: CGRect(x: 0, y: naviBar.yd_bottom, width: view.yd_width, height: view.yd_height - naviBar.yd_bottom))
        contentView.isPagingEnabled = true
        contentView.alwaysBounceHorizontal = true
        contentView.alwaysBounceVertical = false
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.scrollsToTop = false
        contentView.delegate = self
        contentView.layer.masksToBounds = false
        view.addSubview(contentView)
        self.contentViewControllers = _contentViewControllers
        
        let lBtn = UIButton(type: .system)
        lBtn.tintColor = UIColor.white
        lBtn.setImage(#imageLiteral(resourceName: "icon_about"), for: .normal)
        lBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        lBtn.addTarget(self, action: #selector(onAboutClicked(_:)), for: .touchUpInside)
        
        naviBar.leftItem = lBtn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    func onAboutClicked(_ sender: UIButton) -> Void {
        let vc = AboutViewController()
        self.push(with: vc, direction: .bottom)
    }
    
    func checkNewPost() {
        if let vc = contentViewControllers.first as? KZRootContentViewController {
            vc.checkNewPost(thenRefresh: false, forced: true)
        }
    }
    
    //MARK: - UI
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        if scrollView.yd_width == 0 {
            return;
        }
        if Int(offsetX) % Int(scrollView.yd_width) == 0 {
            let index = offsetX / scrollView.yd_width
            let IntIndex = Int(index)
            if IntIndex < 0 || IntIndex >= contentViewControllers.count {
                return
            }
            selectedIndex = IntIndex
            
            let vc = contentViewControllers[IntIndex]
            vc.setNaviBarItem()
            
            if selectedIndex >= 0 && selectedIndex < naviBar.titleBtns.count {
                let btn = naviBar.titleBtns[selectedIndex]
                var point = scrollView.contentOffset
                point.x = point.x * (btn.yd_width + 10) / scrollView.yd_width
                UIView.animate(withDuration: 0.3, animations: { 
                    self.naviBar.titleBtnContentView.setContentOffset(point, animated: false)
                })
            }
        }
    }
    
    func push(with vc: BaseViewController, animated: Bool = true, direction: UITableViewRowAnimation = .right) -> Void {
        vc.nvc = self
        _viewControllers.append(vc)
        if direction == .none && animated {
            vc.view.frame = view.convert(vc.view.frame, to: self.view)
        } else {
            vc.view.frame = CGRect(x: 0, y: 24, width: self.view.yd_width, height: self.view.yd_height - 24)
        }
        view.addSubview(vc.view)
        if animated {
            if direction == .bottom {
                vc.view.yd_y = self.view.yd_bottom
            } else if direction == .fade {
                vc.view.alpha = 0.7
            } else if direction == .left {
                vc.view.yd_x = 0
            } else if direction == .right {
                vc.view.yd_x = view.yd_width
            } else if direction == .middle {
                vc.view.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            } else if direction == .top {
                vc.view.yd_y = 0 - view.yd_height
            } else if direction == .none {
                vc.view.frame = view.convert(vc.view.frame, to: self.view)
            } else {
                vc.view.yd_y = view.yd_width
            }
            vc.view.yd_y = max(24, vc.view.yd_y)
            UIView.animate(withDuration: 0.35, animations: {
                vc.view.alpha = 1
                vc.view.frame = CGRect(x: 0, y: 24, width: self.view.yd_width, height: self.view.yd_height - 24)
            })
        }
    }
    
    func popViewController(animated: Bool, direction: UITableViewRowAnimation = .right) -> Void {
        if let vc = self._viewControllers.last {
            _viewControllers.removeLast()
            if animated {
                UIView.animate(withDuration: 0.35, animations: { 
                    if direction == .bottom {
                        vc.view.yd_y = self.view.yd_bottom
                    } else if direction == .fade {
                        vc.view.alpha = 0.7
                    } else if direction == .left {
                        vc.view.yd_x = 0
                    } else if direction == .right {
                        vc.view.yd_x = self.view.yd_width
                    } else if direction == .middle {
                        vc.view.frame = CGRect(x: self.view.yd_width / 2, y: self.view.yd_height / 2, width: 0, height: 0)
                    } else if direction == .top {
                        vc.view.yd_y = 0 - self.view.yd_height
                    } else if direction == .none {
                        vc.view.alpha = 0.7
                    } else {
                        vc.view.yd_y = self.view.yd_width
                    }
                    }, completion: { (b) in
                        vc.view.removeFromSuperview()
                        vc.nvc = nil
                })
            } else {
                vc.view.removeFromSuperview()
                vc.nvc = nil
            }
        }
    }
    
    func popToRootViewController(animated: Bool) -> Void {
        if animated {
            UIView.animate(withDuration: 0.35, animations: {
                for vc in self._viewControllers {
                    vc.view.alpha = 0
                }
                }, completion: { (b) in
                    for vc in self._viewControllers {
                        vc.view.removeFromSuperview()
                        vc.nvc = nil
                    }
            })
        } else {
            for vc in self._viewControllers {
                vc.view.removeFromSuperview()
                vc.nvc = nil
            }
        }
    }
}
