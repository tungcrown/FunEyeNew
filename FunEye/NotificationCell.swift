//
//  NotificationCell.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var imgVideoThumb: UIImageView!
    
    @IBOutlet weak var uivShowFollowBtn: UIView!
    let notificationsType = ["comment", "like", "follow", "post"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.layer.cornerRadius = imgAvatar.frame.width / 2
        imgAvatar.clipsToBounds = true
    }

    
    func configureCell(notification: Notification) {
        uivShowFollowBtn.hidden = true
        let person = notification.userSender
        
        let postThumb = notification.postThumb
        if postThumb != nil {
            DataService.instance.downloadAndSetImageFromUrl(postThumb!, imgView: imgVideoThumb, imageCache: ViewCommentVC.imageCache)
        }
        
        person.downloadAndSaveCacheImage(imgAvatar)
        var text: String = ""
        
        if notification.type == notificationsType[0] {
            if let content = notification.commentContent {
                text = "vừa nhận xét: " + content
            } else {
                text = "vừa nhận xét"
            }
        } else if notification.type == notificationsType[1] {
            text = "vừa thích bài đăng"
        }else if notification.type == notificationsType[3] {
            text = "đã đăng một video mới"
        }
        
        let time = timeAgoSinceDateString(notification.timeCreate)
        messageTxt.attributedText = setAttrTextFieldUsername(person.username, time: time, text: text, notiId: notification.id)
    }
    
    func configureCellFollow(notification: Notification, tag: Int) {
        let person = notification.userSender
        uivShowFollowBtn.hidden = false
        
        let username = person.username
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
        
        btnFollow.addTarget(NotificationsVC(), action: #selector(NotificationsVC.followFriendsACTION(_:)), forControlEvents: .TouchUpInside)
        uivShowFollowBtn.addSubview(btnFollow)
        let time = timeAgoSinceDateString(notification.timeCreate)
        messageTxt.attributedText = setAttrTextFieldUsername(username, time: time, text: "Đang theo dõi bạn", notiId: notification.id)
        person.downloadAndSaveCacheImage(imgAvatar)
        
    }
    
    func setAttrTextFieldUsername(username: String, time: String, text: String, notiId: String) -> NSAttributedString {
        let str = username + " " + time + "\n" + text
        let textClickLength = username.characters.count
        let myString = NSMutableAttributedString(string: str)
        var myRange = NSRange(location: 0, length: textClickLength) // range of "Swift"
        
        let multipleAttributes = [
            NSForegroundColorAttributeName: UIColor.darkTextColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(15.0),
            "notification": notiId]
        
        myString.addAttributes(multipleAttributes, range: myRange)
        
        let timeLength = time.characters.count
        myRange = NSRange(location: textClickLength + 1, length: timeLength)
        let anotherAttribute = [ NSForegroundColorAttributeName: UIColor.lightGrayColor() ]
        myString.addAttributes(anotherAttribute, range: myRange)
        return myString
    }
}
