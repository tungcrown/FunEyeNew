//
//  LaunchScreenVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/1/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY) != nil {
            ACCESS_TOKEN = "\(NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY))"
            self.performSegueWithIdentifier("FirstFollowVC", sender: nil)
        } else {
            self.performSegueWithIdentifier("FirstFollowVC", sender: nil)
        }
    }

}
