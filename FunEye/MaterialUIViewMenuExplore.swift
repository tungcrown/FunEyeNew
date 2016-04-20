//
//  MaterialUIViewMenuExplore.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class MaterialUIViewMenuExplore: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        /*
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightTextColor().CGColor*/
    }

}
