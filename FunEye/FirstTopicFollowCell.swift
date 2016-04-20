//
//  FirstTopicFollowCell.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/1/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class FirstTopicFollowCell: UITableViewCell {

    @IBOutlet weak var uivCell: UIView!
    
    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var lblTopic: UILabel!
    
    @IBOutlet weak var imgIconCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(topic: Dictionary<String, AnyObject?>) {
        lblTopic.text = topic["name"] as? String
        if let id = topic["_id"] as? Int {
            imgTopic.image = UIImage(named: "category_\(id)")
        }
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imgTopic.bounds
        blurView.alpha = 0.8
        imgTopic.addSubview(blurView)
    }
}
