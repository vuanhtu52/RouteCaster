//
//  ColorTableViewCell.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class ColorTableViewCell: UITableViewCell {

    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var colorName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        colorImage.layer.cornerRadius = 10;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark: .none
        // Configure the view for the selected state
    }
    
}
