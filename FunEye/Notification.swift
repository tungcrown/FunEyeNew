//
//  File.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

class Notification {
    
    private var _id: String!
    private var _userSender: Friend!
    
    private var _postId: String?
    private var _postThumb: String?
    private var _commentContent: String?
    
    private var _type: String!
    private var _timeCreate: String!
    
    var id: String {
        return _id
    }
    
    var userSender: Friend {
        return _userSender
    }
    
    var posId: String? {
        return _postId
    }
    
    var postThumb: String? {
        return _postThumb
    }
    
    var commentContent: String? {
        return _commentContent
    }
    
    var type: String {
        return _type
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["_id"] as? String {
            self._id = id
        }
        
        if let type = dictionary["type"] as? String {
            self._type = type
        }
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let from = dictionary["actorId"] as? Dictionary<String, AnyObject> {
            self._userSender = Friend(dictionary: from)
        } else {
            self._userSender = nil
        }
        
        if let isFollow = dictionary["isFollow"] as? Bool {
            self._userSender.isFollowing = isFollow
        }
        
        if let from = dictionary["articleId"] as? Dictionary<String, AnyObject> {
            if let postId = from["id"] as? String {
                self._postId = postId
            }
            
            if let postThumb = from["videothumb"] as? String {
                self._postThumb = postThumb
            } else {
                self._postThumb = URL_AVATAR_NIL
            }
        }
        
        if let comment = dictionary["commentId"] as? Dictionary<String, AnyObject> {
            if let content = comment["content"] as? String {
                self._commentContent = content
            }
        } else {
            self._commentContent = nil
        }
        
    }
    
}