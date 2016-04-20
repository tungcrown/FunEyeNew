//
//  ProfileVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/7/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ProfileVC: ViewController {
    
    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var imgUserCover: UIImageView!
    
    @IBOutlet weak var uivImageCover: UIView!
    @IBOutlet weak var uivSettingOrFollow: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCountFollowers: UILabel!
    @IBOutlet weak var lblCountFollowing: UILabel!
    
    var userId: String!
    var userAvatar: String!
    var userName: String!
    
    var user: Friend!
    
    var postUserPost = [Post]()
    var postUserLike = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
        configureImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if userId == USER_ID {
            setupTabSetting()
        } else {
            setupTabFollow()
        }
        
    }
    
    func setupTabFollow() {
        uivSettingOrFollow.layer.cornerRadius = 3.0
        
        let bounds = uivSettingOrFollow.bounds
        let label = UILabel(frame: bounds)
        label.textAlignment = NSTextAlignment.Center
        label.text = "Following"
        label.textColor = UIColor.whiteColor()
        
        let image = UIImage(named: "follow-not")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(5.0, 5.0, 25, 25)
        
        uivSettingOrFollow.addSubview(label)
        uivSettingOrFollow.addSubview(imageView)
        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(ProfileVC.followAction(_:)))
        tap.numberOfTapsRequired = 1
        uivSettingOrFollow.userInteractionEnabled = true
        uivSettingOrFollow.addGestureRecognizer(tap)
    }
    
    func setupTabSetting() {
        uivSettingOrFollow.layer.cornerRadius = 3.0
//        uivSettingOrFollow.layer.borderWidth = 2.0
//        uivSettingOrFollow.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        let bounds = uivSettingOrFollow.bounds
        let label = UILabel(frame: bounds)
        label.textAlignment = NSTextAlignment.Center
        label.text = "Cài đặt"
        label.textColor = UIColor.whiteColor()
        
        let image = UIImage(named: "setting")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(5.0, 5.0, 25, 25)
        
        uivSettingOrFollow.addSubview(label)
        uivSettingOrFollow.addSubview(imageView)
        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(ProfileVC.showSettingVC(_:)))
        tap.numberOfTapsRequired = 1
        uivSettingOrFollow.userInteractionEnabled = true
        uivSettingOrFollow.addGestureRecognizer(tap)
    }
    
    func followAction(sender: UITapGestureRecognizer) {
        print("follow tap")
    }
    
    func showSettingVC(sender: UITapGestureRecognizer) {
        if let settingVC = storyboard!.instantiateViewControllerWithIdentifier("SettingVC") as? SettingVC {
            self.navigationController?.showViewController(settingVC, sender: nil)
        }
    }
    
    override func getPostFromAlamofire(url: String) {
        if userId == nil {
            userId = USER_ID
        }
        
        if userName != nil {
            user = Friend(name: userName, id: userId, avatarUrl: userAvatar, message: "")
            configureInfoUser()
        }
        
        let url = URL_USER_GET_POST(userId)
        print("url \(url)")
        getPostFromUrl(url, isLikePost: false)
    }
    
    func getPostFromUrl(url: String, isLikePost: Bool) {
        let nsUrl = NSURL(string: url)!
        Alamofire.request(.GET, nsUrl).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("load new data")
                    self.indicator.stopAnimating()
                    //self.posts = [Post]()
                    for json in jsons {
                        let post = Post(dictionary: json)
                        DataService.instance.addPost(post)
                        //self.posts.insert(post, atIndex: 0)
                        if isLikePost {
                            self.postUserLike.insert(post, atIndex: 0)
                            self.configureDataPost(self.postUserLike)
                        } else {
                            self.postUserPost.insert(post, atIndex: 0)
                            self.configureDataPost(self.postUserPost)
                        }
                        
                        //self.tableView.reloadData()
                    }
                }
            } else {
                self.indicator.stopAnimating()
                print(response)
            }
        }
    }
    
    func loadUserInfo() {
        if userId != nil {
            let url = URL_USER_GET_INFO(userId)
            Alamofire.request(.GET, url).responseJSON { response in
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    self.user = Friend(dictionary: res)
                    self.configureInfoUser()
                } else {
                    print(response)
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tappedViewFollow(_:)))
        tap.numberOfTapsRequired = 1
        lblCountFollowers.tag = 1
        lblCountFollowers.userInteractionEnabled = true
        lblCountFollowers.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.tappedViewFollow(_:)))
        tap2.numberOfTapsRequired = 1
        lblCountFollowing.tag = 2
        lblCountFollowing.userInteractionEnabled = true
        lblCountFollowing.addGestureRecognizer(tap2)
    }
    
    func configureDataPost(data: [Post]) {
        posts = data
        tableView.reloadData()
    }
    
    func configureInfoUser() {
        lblUserName.text = user.name
        
        DataService.instance.downloadAndSetImageFromUrl(user.avatarUrl, imgView: imgUserAvatar, imageCache: ViewController.imageCache)
        DataService.instance.downloadAndSetImageFromUrl(user.avatarUrl, imgView: imgUserCover, imageCache: ViewController.imageCache)
        
        if user.arrayFollower != nil {
            lblCountFollowers.text = "\(user.arrayFollower!.count) Followers"
        }
        
        if user.arrayFollowing != nil {
            lblCountFollowing.text = "\(user.arrayFollowing!.count) Following"
        }
    }
    
    func configureImage() {
        imgUserAvatar.layer.cornerRadius = imgUserAvatar.layer.frame.width / 2
        imgUserAvatar.layer.borderWidth = 3.0
        imgUserAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        
        imgUserAvatar.clipsToBounds = true
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imgUserCover.bounds
        imgUserCover.addSubview(blurView)
        
    }
    
    func tappedViewFollow(sender: UITapGestureRecognizer) {
        
        if let viewFollowVC = storyboard!.instantiateViewControllerWithIdentifier("ViewFollowVC") as? ViewFollowVC {
            viewFollowVC.userId = userId
            if sender.view?.tag == 1 {
                viewFollowVC.isFollowerTab = true
            } else {
                viewFollowVC.isFollowerTab = false
            }
            
            self.navigationController?.showViewController(viewFollowVC, sender: nil)
        }
    }
    
    @IBAction func sgmChangeACTION(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            if postUserPost.count > 0 {
                configureDataPost(postUserLike)
            }
        } else {
            if postUserLike.count > 0 {
                configureDataPost(postUserLike)
            } else {
                let url = URL_USER_GET_POST_LIKE(userId)
                print("url \(url)")
                getPostFromUrl(url, isLikePost: true)
            }
        }
    }
    
}
