//
//  SettingVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/15/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class SettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var imgUserAvatar: UIImageView!
  
    var user: Friend!
    var settings = [Dictionary<String, String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.dataSource = self
        tableview.delegate = self
        
        configureImage()
        loadUserInfo()
       /*
        var settingPart = ["text": "Họ Tên", "value" : "Tung Crown", "type": "text"]
        settings.append(settingPart)
        
        settingPart = ["text": "Username", "value" : "tungbkdn09", "type": "text"]
        settings.append(settingPart)
        
        settingPart = ["text": "Email", "value" : "tungbkdn09@gmail.com", "type": "text"]
        settings.append(settingPart)
        
        settingPart = ["text": "Password", "value" : "tungbkdn09@gmail.com", "type": "text"]
        settings.append(settingPart)
    */
    }
    
    func configureImage() {
        imgUserAvatar.layer.cornerRadius = imgUserAvatar.layer.frame.width / 2
        imgUserAvatar.layer.borderWidth = 3.0
        imgUserAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        
        imgUserAvatar.clipsToBounds = true
        
        
    }
    
    func loadUserInfo() {
        let url = URL_USER_GET_INFO(USER_ID)
        print("url \(url)")
        Alamofire.request(.GET, url).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                self.user = Friend(dictionary: res)
                self.configureInfoUser()
                
                if let name = res["fullName"] as? String {
                    let settingPart = ["text": "Họ Tên", "value" : "\(name)" , "type": "text"]
                    self.settings.append(settingPart)
                }
                
                if let name = res["username"] as? String {
                    let settingPart = ["text": "Username", "value" : "\(name)" , "type": "text"]
                    self.settings.append(settingPart)
                }
                
                if let name = res["avatar"] as? String {
                    let settingPart = ["text": "Email", "value" : "\(name)" , "type": "text"]
                    self.settings.append(settingPart)
                }
                
                if let name = res["avatar"] as? String {
                    let settingPart = ["text": "Password", "value" : "tungbkdn09@gmail.com", "type": "pass"]
                    self.settings.append(settingPart)
                }
                
                self.tableview.reloadData()
            } else {
                print(response)
            }
        }
    }
    
    func configureInfoUser() {
        //lblUserName.text = user.name
        DataService.instance.downloadAndSetImageFromUrl(user.avatarUrl, imgView: imgUserAvatar, imageCache: ViewController.imageCache)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell") as? SettingCell {
            let setting = settings[indexPath.row]
            print("settings \(setting)")
            cell.configureCell(setting)
            
            return cell
        } else {
            return SettingCell()
        }
    }
    
}
