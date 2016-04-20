//
//  FollowCell.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/7/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class FollowCell: FirstFollowCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func configureCell(friend: Friend) {
        super.configureCell(friend)
    }
    /*
    @IBOutlet weak var imgAvtUsers: UIImageView!
    @IBOutlet weak var lblUserFriendName: UILabel!
    @IBOutlet weak var lblSourceFriends: UILabel!
    
    @IBOutlet weak var btnFollowFriends: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvtUsers.layer.cornerRadius = imgAvtUsers.layer.frame.width / 2
        imgAvtUsers.clipsToBounds = true
        
        btnFollowFriends.layer.cornerRadius = 2.0
        btnFollowFriends.clipsToBounds = true
    }
    
    func configureCell(friend: Friend) {
        lblUserFriendName.text = friend.name
        //lblSourceFriends.text = friend.message
        DataService.instance.downloadAndSetImageFromUrl(friend.avatarUrl, imgView: imgAvtUsers, imageCache: FirstFollowVC.imageCache)
    }*/
}
