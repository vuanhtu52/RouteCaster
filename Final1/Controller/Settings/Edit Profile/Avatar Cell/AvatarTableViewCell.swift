//
//  AvatarTableViewCell.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/9/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class AvatarTableViewCell: UITableViewCell {

    @IBOutlet weak var changeAva: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    var changeAvaButtonAction : (() -> ())?
    //@IBOutlet weak var displayedName: UILabel!
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        self.changeAva.addTarget(self, action: #selector(changeAvaDidTap(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changeAvaDidTap(_ sender: Any) {
        //handleSelectProfileImageView()
        changeAvaButtonAction?()
    }
}

