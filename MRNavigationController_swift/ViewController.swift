//
//  ViewController.swift
//  MRNavigationController_swift
//
//  Created by max ren on 16/11/23.
//  Copyright © 2016年 MR. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.whiteColor()
        
        let btn = UIButton(frame: CGRect(x: view.frame.width / 2 - 100, y: view.frame.height / 2.0, width: 200, height: 30))
        btn.backgroundColor = UIColor.purpleColor()
        btn.setTitle("push \(navigationController?.viewControllers.count ?? 0)", forState: .Normal)
        btn.addTarget(self, action: #selector(touchInside), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func touchInside() {
        let vc = ViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }

}

