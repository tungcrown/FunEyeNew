//
//  Comment.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/31/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

class Comment {
    private var _id: String!
    private var _user: Friend!
    private var _caption: String!
    private var _timeCreate: String!
    
    var id: String {
        return _id
    }
    
    var user: Friend {
        return _user
    }
    
    var caption: String {
        if _caption != nil {
            return _caption
        } else {
            return " "
        }
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["_id"] as? String {
            self._id = id
        }
        
        if let from = dictionary["from"] as? Dictionary<String, AnyObject> {
            self._user = Friend(dictionary: from)
        }
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let caption = dictionary["content"] as? String {
            self._caption = caption
        }
    }
}
