//
//  firends.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//
import Alamofire

class Friend {
    private var _name: String!
    private var _id: String!
    private var _avatarUrl: String!
    private var _message: String!
    private var _username: String!
    
    private var _arrayFollower: [String]?
    private var _arrayFollowing: [String]?
    private var _isFollowing: Bool = false
    
    private var imageAvatarCache = NSCache()
    private var _avatarUIImage: UIImage!
    
    var name: String {
        return _name
    }
    
    var arrayFollower: [String]? {
        return _arrayFollower
    }
    
    var arrayFollowing: [String]? {
        return _arrayFollowing
    }
    
    var isFollowing: Bool {
        get {
            return _isFollowing
        }
        set {
            self._isFollowing = newValue
        }
    }
    
    var username: String {
        return _username
    }
    
    var id: String {
        return _id
    }
    
    var avatarUrl: String {
        return _avatarUrl
    }
    
    var avatarUIImage: UIImage {
        return _avatarUIImage
    }
    
    var message: String {
        return _message
    }
    
    init(name: String, id: String, avatarUrl: String?, message: String?) {
        self._name = name
        self._id = id
        if avatarUrl == nil {
            self._avatarUrl = URL_AVATAR_NIL
        } else {
            self._avatarUrl = avatarUrl
        }
        if message == nil {
            self._message = ""
        } else {
            self._message = message
        }
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["id"] as? String {
            self._id = id
        }
        
        if let name = dictionary["fullName"] as? String {
            self._name = name
        }
        
        if let avatar = dictionary["avatar"] as? String {
            self._avatarUrl = avatar
        } else {
            self._avatarUrl = URL_AVATAR_NIL
        }
        
        self._message = ""
        
        if let arFollower = dictionary["follower"] as? [Int] {
            self._arrayFollower = arFollower.map(
                {
                    (number: Int) -> String in
                    return String(number)
            })
            if arFollower.count > 0 {
                if arFollower.contains(Int(USER_ID)!){
                    self._isFollowing = true
                }
            }
        } else {
            self._arrayFollower = nil
        }
        
        if let arFollowing = dictionary["following"] as? [Int] {
            self._arrayFollowing = arFollowing.map(
                {
                    (number: Int) -> String in
                    return String(number)
            })
        } else {
            self._arrayFollowing = nil
        }
        
        if let username = dictionary["username"] as? String {
            self._username = username
        }
        
        if let provider = dictionary["provider"] as? String {
            self._message = provider
        }
        
        //downloadAndSaveCacheImage()
    }
    
    func followFriends() {
        let isFollowing = !self._isFollowing
        Alamofire.request(.PUT, URL_PUT_FOLLOW_FRIEND(self._id, isFollow: isFollowing))
        self._isFollowing = isFollowing
    }
    
    func viewProfileDetail(uiviewcontroller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewControllerWithIdentifier("ProfileVC") as? ProfileVC {
            profileVC.userId = _id
            profileVC.userAvatar = _avatarUrl
            profileVC.userName = _name
            uiviewcontroller.navigationController?.showViewController(profileVC, sender: nil)
        }
    }
    
    func downloadAndSaveCacheImage(imageView: UIImageView) {
        let url = _avatarUrl
        let img = imageAvatarCache.objectForKey(url) as? UIImage
        if img != nil {
            imageView.image = img
        } else {
            Alamofire.request(.GET, url).validate(contentType: ["image/*"]).response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let img = UIImage(data: data!)!
                    imageView.image = img
                    //save cache
                    self.imageAvatarCache.setObject(img, forKey: url)
                }
            })
        }
    }
}