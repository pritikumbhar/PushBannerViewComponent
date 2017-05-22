//
//  ViewController.swift
//  PushBannerViewComponent
//
//  Created by Priti on 18/04/17.
//  Copyright © 2017 com.perennial. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func showPushBannerViewAction(_ sender: AnyObject) {
        
        PushBannerView.sharedInstance()?.showNotificationWithMessage(message: "Hello, these is testing message", clickClosure: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

}

