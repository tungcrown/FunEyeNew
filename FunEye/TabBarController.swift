//
//  TabBarController.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/10/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class TabBarController: UITabBarController {
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://funeye.net:8080")!, options: [.Log(false), .ForcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let tabItems = self.tabBar.items! as [UITabBarItem]
        
        
        let itemIndex: CGFloat = 2
        let bgColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items!.count)
        let bgView = UIView(frame: CGRectMake(itemWidth * itemIndex, 0, itemWidth, tabBar.frame.height))
        bgView.backgroundColor = bgColor
        tabBar.insertSubview(bgView, atIndex: 0)
        
        setupSocketIO()
    }
    
    func setupSocketIO() {
        socket.on("notification") {data, ack in
            let tabItems = self.tabBar.items! as [UITabBarItem]
            tabItems[3].badgeValue = "1"
        }
        
        socket.on("connect") {data, ack in
            self.socket.emit("username", USER_ID)
        }
        socket.connect()
    }
}
