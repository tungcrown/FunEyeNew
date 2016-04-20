//
//  ShowExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SocketIOClientSwift

class ShowExploreVC: ViewController {
    
    var data: String!
    var cateName: String!
    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingBackgroundNavigationController()
        //self.navigationController?.title = cateName
    }
    
    override func getPostFromAlamofire(url: String) {
        let url: String!
        if type == "category" {
            url = URL_GET_CATEGORY_POST(data)
        } else if type == "hot" {
            url = URL_GET_POST_HOT(data, page: 1)
        } else {
            let hashtag = String(data.characters.dropFirst())
            url = URL_GET_POST_HASHTAG(hashtag, page: 1)
        }
        
        print("url load data category \(url)")
        let nsUrl = NSURL(string: url)!
        
        Alamofire.request(.GET, nsUrl).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("load new data")
                    self.indicator.stopAnimating()
                    self.posts = [Post]()
                    for json in jsons {
                        let post = Post(dictionary: json)
                        DataService.instance.addPost(post)
                        self.posts.insert(post, atIndex: 0)
                        self.tableView.reloadData()
                    }
                }
            } else {
                print(response)
            }
        }
    }
    
    func settingBackgroundNavigationController() {
        if type == "category" {
            if let image = UIImage(named: "category_\(data)") {
                self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.setBackgroundImage(image,
                                                                            forBarMetrics: .Default)
            }
        } else if type == "hot" {
            if data == "created" {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 36/255, green: 173/255, blue: 95/255, alpha: 1.0)
            } else if data == "hot" {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 47/255, blue: 67/255, alpha: 1.0)
            } else if data == "featured" {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
            }
        }
        self.title = cateName
    }
}

