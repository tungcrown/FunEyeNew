//
//  Exploder.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class ExploreCell: UITableViewCell {
    
    @IBOutlet weak var uivCategory: UIView!
    
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    
    @IBOutlet weak var btnChooseCategory: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uivCategory.layer.cornerRadius = 3.0
        uivCategory.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        uivCategory.layer.shadowOpacity = 0.4
        uivCategory.layer.shadowRadius = 5.0
        uivCategory.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        uivCategory.clipsToBounds = true
    
    }
    
    func configureCell(topic: Dictionary<String, AnyObject?>) {
        
        lblCategory.text = topic["name"] as? String
        if let id = topic["_id"] as? Int {
            imgCategory.image = UIImage(named: "category_\(id)")
        }
    }
}
