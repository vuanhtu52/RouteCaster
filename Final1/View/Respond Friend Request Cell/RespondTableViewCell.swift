//
//  RespondTableViewCell.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/13/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class RespondTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var notiContent: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    var acceptBtnTapped : (() -> ())?
    var declineBtnTapped : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        acceptBtn.layer.cornerRadius = 10
        declineBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func declineBtnDidTap(_ sender: Any) {
        declineBtnTapped?()
    }
    @IBAction func acceptBtnDidTap(_ sender: Any) {
        acceptBtnTapped?()
    }
}
