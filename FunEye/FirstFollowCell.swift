//
//  FirstFollowCell.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class FirstFollowCell: UITableViewCell {
    
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
        lblSourceFriends.text = friend.message
        DataService.instance.downloadAndSetImageFromUrl(friend.avatarUrl, imgView: imgAvtUsers, imageCache: FirstFollowVC.imageCache)
        
        if friend.isFollowing == true {
            let img = UIImage(named: "follow-active")
            btnFollowFriends.setImage(img, forState: .Normal)
        } else {
            let img = UIImage(named: "follow-not")
            btnFollowFriends.setImage(img, forState: .Normal)
        }
    }
}