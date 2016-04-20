//
//  SettingCell.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/15/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var uivewSetting: UIView!
    @IBOutlet weak var txtInputSetting: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(setting: Dictionary<String, String>) {

        lblSetting.text = setting["text"]
        txtInputSetting.text = setting["value"]
        if let type = setting["type"] where type == "text" {
            //let txtField = UITextField(frame: <#T##CGRect#>)
        }
    }
}
