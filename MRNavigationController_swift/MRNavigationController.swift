//
//  MRNavigationViewController.swift
//  MRNavigationController_swift
//
//  Created by max ren on 2016/12/28.
//  Copyright © 2016年 MR. All rights reserved.
//

import UIKit

/**
  专场方式
 
 - horizon: push pop转场，由左到右
 - scale: 带有放缩效果的push,pop转场
 */
enum TransitionType {
    case horizon
    case scale
}

class MRNavigationController: UINavigationController {

    var transitionType: TransitionType = .horizon
    
    private var containerView: UIView? {
        return UIApplication.sharedApplication().keyWindow?
            .rootViewController?.view
    }
    
    private let xOff: CGFloat = UIScreen.mainScreen().bounds.width
    
    private var screenShotStack: [UIImage] = []
    private var backgroundView: UIView?
    private var maskView: UIView?
    private var lastScreentShotView: UIImageView?
    
    private var timer: NSTimer?
    private var time: CGFloat = 0
    
    private var isTransiting: Bool = false //是否正在转场
    private var locatorPoint: CGPoint = CGPoint.zero //初始触碰点
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if self.respondsToSelector(Selector("interactivePopGestureRecognizer")) {
            self.view.removeGestureRecognizer(interactivePopGestureRecognizer!)
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognize(_:)))
            pan.delegate = self
            pan.delaysTouchesBegan = true
            self.view.addGestureRecognizer(pan)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MRNavigationController: UIGestureRecognizerDelegate {
    
    func panGestureRecognize(recognizer: UIPanGestureRecognizer) {
        guard viewControllers.count > 1 else { return }
        let touchPoint = recognizer.locationInView(UIApplication.sharedApplication().keyWindow)
        switch recognizer.state {
        case .Began:
               isTransiting = true
               locatorPoint = touchPoint
                if self.backgroundView == nil {
                    let frame = UIScreen.mainScreen().bounds
                    self.backgroundView = UIView(frame: frame)
                   self.containerView?.superview?.insertSubview(self.backgroundView!, belowSubview: self.containerView!)
                    
                    maskView = UIView(frame: frame)
                    maskView?.backgroundColor = UIColor.blackColor()
                    self.backgroundView!.addSubview(maskView!)
                }
            
                self.backgroundView?.hidden = false
                lastScreentShotView?.removeFromSuperview()
            
                let lastScreenShot = screenShotStack.last
                lastScreentShotView = UIImageView(image: lastScreenShot)
               
                self.backgroundView?.insertSubview(lastScreentShotView!, belowSubview: maskView!)
        case .Ended:
            if touchPoint.x - locatorPoint.x > 50 {
                UIView.animateWithDuration(0.3, animations: {
                      self.moveViewWithX(self.xOff)
                    }, completion: { (_) in
                        self.popViewControllerAnimated(false)
                        let frame = UIScreen.mainScreen().bounds
                        self.containerView?.frame = frame
                        
                        self.isTransiting = false
                        self.backgroundView?.hidden = true
                })
            }else {
                UIView.animateWithDuration(0.3, animations: { 
                    self.moveViewWithX(0)
                    }, completion: { (_) in
                        self.isTransiting = false
                        self.backgroundView?.hidden = true
                })
            }
            return
        case .Cancelled:
            UIView.animateWithDuration(0.3, animations: { 
                self.moveViewWithX(0)
                }, completion: { (_) in
                    self.isTransiting = false
                    self.backgroundView?.hidden = true
            })
            return
        default:
            break
        }
        
        
        if isTransiting {
            self.moveViewWithX(touchPoint.x - locatorPoint.x)
        }
    }
}


extension MRNavigationController {
    
    func capture() -> UIImage? {
        guard containerView != nil else { return nil }
        UIGraphicsBeginImageContextWithOptions(containerView!.bounds.size, containerView!.opaque, 0.0)
        containerView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        if let snapshot = capture() {
            screenShotStack.append(snapshot)
        }
        if viewControllers.count > 0 {
            let backItem = UIBarButtonItem(image: UIImage(named: "ic_navigate_before_white_36dp"), style: .Plain, target: self, action: #selector(popViewController))
            viewController.navigationItem.leftBarButtonItem = backItem
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        screenShotStack.removeLast()
        return super.popViewControllerAnimated(animated)
    }
    
    func popViewController() -> UIViewController? {
        UIView.animateWithDuration(0.3) {
            if self.backgroundView == nil {
               let frame = UIScreen.mainScreen().bounds
               self.backgroundView = UIView(frame: frame)
 
               self.containerView?.superview?.insertSubview(self.backgroundView!, belowSubview: self.containerView!)
 
               self.maskView = UIView(frame: frame)
               self.maskView?.backgroundColor = UIColor.blackColor()
                
               self.backgroundView?.addSubview(self.maskView!)
            }
            
            self.backgroundView?.hidden = false
            self.lastScreentShotView?.removeFromSuperview()
            
            let lastScreentShot = self.screenShotStack.last
            self.lastScreentShotView = UIImageView(image: lastScreentShot)
            
            self.backgroundView?.insertSubview(self.lastScreentShotView!, belowSubview: self.maskView!)
            
            self.time = 0
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(self.backAnimation), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        }
        return viewControllers.last
    }
    
    
    func backAnimation() {
        self.time += 1
        moveViewWithX(xOff/6 * time)
        if time == 6 {
            self.popViewControllerAnimated(false)
            var frame = UIScreen.mainScreen().bounds
            frame.origin.x = 0
            containerView?.frame = frame
            backgroundView?.hidden = true
            timer?.invalidate()
        }
    }

    private func moveViewWithX(x: CGFloat) {
        var xOffset = x > xOff ? xOff : x
        xOffset = x < 0 ? 0 : x
        
        var frame = containerView!.frame
        frame.origin.x = xOffset
        containerView?.frame = frame
        
        let scale = xOffset/xOff * 0.05 + 0.95
        let alpha = 0.4 - xOffset/xOff * 0.4
        
        switch transitionType {
        case .horizon:
            lastScreentShotView?.transform = CGAffineTransformMakeTranslation(-xOff/2 + xOffset/2, 0)
        case .scale:
            lastScreentShotView?.transform = CGAffineTransformMakeScale(scale, scale)
        }
        maskView?.alpha = alpha
     }
    
}


