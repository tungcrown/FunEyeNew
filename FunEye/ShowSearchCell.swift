//
//  ShowSearchCell.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/15/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit


class ShowSearchCell: UITableViewCell {
    
    
    @IBOutlet weak var uivContainerCell: UIView!
    @IBOutlet weak var uivShowFollowBtn: UIView!
    
    @IBOutlet weak var imgUserAvt: UIImageView!
    @IBOutlet weak var imgVideoThumb: UIImageView!
    
    @IBOutlet weak var textViewData: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgUserAvt.layer.cornerRadius = imgUserAvt.layer.frame.size.width / 2
        imgUserAvt.clipsToBounds = true
    }
    
    func configureCellUser(person: Friend, tag: Int) {
        let username = person.name
        var image: UIImage!
        if person.isFollowing {
            image = UIImage(named: "follow-active")
        } else {
            image = UIImage(named: "follow-not")
        }
        
        let frame = CGRectMake(8, 8, 25, 25)
        let btnFollow = UIButton(frame: frame)
        btnFollow.setBackgroundImage(image, forState: .Normal)
        btnFollow.tag = tag
        
        for subviews in uivShowFollowBtn.subviews {
            subviews.removeFromSuperview()
        }
        
        btnFollow.addTarget(ExploreVC(), action: #selector(ExploreVC.followFriendsACTION(_:)), forControlEvents: .TouchUpInside)
        uivShowFollowBtn.addSubview(btnFollow)
        
        textViewData.attributedText = setAttrTextFieldUsername(username, text: "", userId: person.id)
        DataService.instance.downloadAndSetImageFromUrl(person.avatarUrl, imgView: imgUserAvt, imageCache: ViewController.imageCache)

    }
   
    func configureCellPost(post: Post) {
        let username = post.userName
        let userId = post.userId
       
        textViewData.attributedText = setAttrTextFieldUsername(username, text: post.caption, userId: userId)
        
        DataService.instance.downloadAndSetImageFromUrl(post.userAvatar, imgView: imgUserAvt, imageCache: ViewController.imageCache)
        DataService.instance.downloadAndSetImageFromUrl(post.videoThumb, imgView: imgVideoThumb, imageCache: ViewController.imageCache)
        
    }
    
    func configureCellHashtag(name: String, count: String) {
        textViewData.text = name
    }
    
    func setAttrTextFieldUsername(username: String, text: String, userId: String) -> NSAttributedString {
        let str = username + "\n" + text
        let textClickLength = username.characters.count
        let myString = NSMutableAttributedString(string: str)
        let myRange = NSRange(location: 0, length: textClickLength) // range of "Swift"
        
        let userId = userId
        let multipleAttributes = [
            NSForegroundColorAttributeName: UIColor.darkTextColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0),
            "username": userId]
        
        myString.addAttributes(multipleAttributes, range: myRange)
        return myString
    }
}

