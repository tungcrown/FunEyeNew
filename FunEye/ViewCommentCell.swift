//
//  ViewCommentCell.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/31/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class ViewCommentCell: UITableViewCell {

    @IBOutlet weak var uivContainerCell: UIView!
    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCreateTime: UILabel!
    
    @IBOutlet weak var txtviewCaption: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgUserAvatar.layer.cornerRadius = imgUserAvatar.frame.width / 2
        imgUserAvatar.clipsToBounds = true
        
        txtviewCaption.textContainerInset =
            UIEdgeInsetsMake(0,-5,0,0);
    }
    
    func configureCell(comment: Comment) {
        let person = comment.user
        person.downloadAndSaveCacheImage(imgUserAvatar)
        lblUserName.text = person.username
        lblCreateTime.text = timeAgoSinceDateString(comment.timeCreate)
        let str = comment.caption
        txtviewCaption.attributedText = setAttrWithName("Hashtag", wordPrefix: "#", color: UIColor.brownColor(), text: str)
    }
    
    func setAttrWithName(attrName: String, wordPrefix: String, color: UIColor, text: String) -> NSAttributedString {
        let words = text.componentsSeparatedByString(" ")
        let attrString = NSMutableAttributedString(string: text)
        let textString = NSString(string: text)
        
        for word in words.filter({$0.hasPrefix(wordPrefix)}) {
            let range = textString.rangeOfString(word)
            attrString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            let singleAttribute = [attrName: word]
            attrString.addAttributes(singleAttribute, range: range)
        }
        /*
        for word in words.filter({$0.hasPrefix("@")}) {
            let range = textString.rangeOfString(word)
            attrString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            let singleAttribute = [attrName: word]
            attrString.addAttributes(singleAttribute, range: range)
        }*/
        return attrString
    }
}
