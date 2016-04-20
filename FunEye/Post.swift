//
//  Post.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/22/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//
import UIKit
import AVKit
import Foundation
import AVFoundation
import Alamofire

class Post: NSObject, NSCoding {
    private var _postId: String!
    
    private var _caption: String!
    private var _videoUrl: String!
    private var _videoPath: String!
    private var _videoThumb: String!
    private var _timeCreate: String!
    
    private var _userId: String!
    private var _userName: String!
    private var _userAvatar: String!
    
    private var _likes: Int!
    private var _comments: Int!
    private var _views: Int!
    private var _shares: Int!
    
    private var Observer: NSObjectProtocol!
    private var _uiviewVideo: UIView!
    
    private var _isLikePost: Bool = false
    
    var postId: String {
        return _postId
    }
    
    var caption: String {
        return _caption
    }
    
    var videoUrl: String {
        return _videoUrl
    }
    
    var isLikePost: Bool {
        get {
            return _isLikePost
        }
        set {
            _isLikePost = newValue
        }
        
    }
    
    var videoThumb: String {
        if _videoThumb == nil {
            return "http://funeye.net:8000/img/logo-full.png"
        } else {
            return _videoThumb
        }
    }
    
    var videoPath: String {
        get {
            if _videoPath == nil {
                return ""
            } else {
                return _videoPath
            }
        }
        
        set {
            _videoPath = newValue
        }
    }
    
    var userId: String {
        return _userId
    }
    
    var userName: String {
        return _userName
    }
    
    var userAvatar: String {
        return _userAvatar
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    
    var views: Int {
        get {
            return _views
        }
        
        set {
            self._views = newValue
        }
    }
    
    var likes: Int {
        get {
            return _likes
        }
        set {
            _likes = newValue
        }
    }
    
    var comments: Int {
        return _comments
    }
    
    var shares: Int {
        return _shares
    }
    
    //testing
   
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let id = dictionary["id"] as? String {
            self._postId = id
        }
        
        if let videoUrl = dictionary["videourl"] as? String {
            self._videoUrl = videoUrl
        }
        
        if let caption = dictionary["content"] as? String {
            self._caption = caption
        }
        
        if let likes = dictionary["likesCount"] as? Int {
            self._likes = likes
        }
        
        if let comments = dictionary["comments"] as? Int {
            self._comments = comments
        }
        
        if let views = dictionary["views"] as? Int {
            self._views = views
        }
        
        if let thumb = dictionary["videothumb"] as? String {
            self._videoThumb = thumb
        }
        /*
        if let shares = dictionary["shares"] as? Int {
            self._shares = shares
        }*/
        
        self._shares = 0
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let arrayUser = dictionary["creator"] as? Dictionary<String, AnyObject> {
            if let userId = arrayUser["id"] as? String {
                self._userId = userId
            }
            if let userName = arrayUser["fullName"] as? String {
                self._userName = userName
            }
            
            if let userAvatar = arrayUser["avatar"] as? String {
                self._userAvatar = userAvatar
            } else {
                self._userAvatar = URL_AVATAR_NIL
            }
            
        }
        
        if let arrayLikes = dictionary["likes"] as? [Int] {
            if arrayLikes.count == 0 {
                self._isLikePost = false
            } else {
                if arrayLikes.contains(Int(USER_ID)!){
                    self._isLikePost = true
                } else {
                    self._isLikePost = false
                }
            }
        } else {
            self._isLikePost = false
        }
    }
    
    override init() {
        
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self._postId = aDecoder.decodeObjectForKey("postId") as? String
        self._caption = aDecoder.decodeObjectForKey("caption") as? String
        self._videoUrl = aDecoder.decodeObjectForKey("videoUrl") as? String
        self._videoPath = aDecoder.decodeObjectForKey("videoPath") as? String
        self._videoThumb = aDecoder.decodeObjectForKey("videoThumb") as? String
        self._timeCreate = aDecoder.decodeObjectForKey("timeCreate") as? String
        self._userId = aDecoder.decodeObjectForKey("userId") as? String
        self._userName = aDecoder.decodeObjectForKey("userName") as? String
        self._userAvatar = aDecoder.decodeObjectForKey("userAvatar") as? String
        self._likes = aDecoder.decodeObjectForKey("likes") as? Int
        self._comments = aDecoder.decodeObjectForKey("comments") as? Int
        self._views = aDecoder.decodeObjectForKey("views") as? Int
        self._shares = aDecoder.decodeObjectForKey("shares") as? Int
        self._isLikePost = aDecoder.decodeObjectForKey("isLikePost") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._postId, forKey: "postId")
        aCoder.encodeObject(self._caption, forKey: "caption")
        aCoder.encodeObject(self._videoUrl, forKey: "videoUrl")
        aCoder.encodeObject(self._videoPath, forKey: "videoPath")
        aCoder.encodeObject(self._videoThumb, forKey: "videoThumb")
        aCoder.encodeObject(self._timeCreate, forKey: "timeCreate")
        aCoder.encodeObject(self._userId, forKey: "userId")
        aCoder.encodeObject(self._userName, forKey: "userName")
        aCoder.encodeObject(self._userAvatar, forKey: "userAvatar")
        aCoder.encodeObject(self._likes, forKey: "likes")
        aCoder.encodeObject(self._comments, forKey: "comments")
        aCoder.encodeObject(self._views, forKey: "views")
        aCoder.encodeObject(self._shares, forKey: "shares")
        aCoder.encodeObject(self._isLikePost, forKey: "isLikePost")
    }
}
