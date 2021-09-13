//
//  StatisticHeaderTableViewCell.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/16/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class StatisticHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var dateMonth: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var decrease: UIButton!
    @IBOutlet weak var increase: UIButton!
    var increaseFunc : (() -> ())?
    var decreaseFunc : (() -> ())?
    var segmentFunc : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func segmentChanged(_ sender: Any) {
        segmentFunc?()
    }
    @IBAction func decreaseTapped(_ sender: Any) {
        decreaseFunc?()
    }
    @IBAction func increaseTapped(_ sender: Any) {
        increaseFunc?()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
