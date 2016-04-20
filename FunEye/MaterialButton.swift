//
//  MaterialView.swift
//  social network for iOS9 with
//
//  Created by Lê Thanh Tùng on 3/18/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class MaterialButton: UIButton{
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }
    
}