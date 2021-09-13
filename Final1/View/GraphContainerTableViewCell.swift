//
//  GraphContainerTableViewCell.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/16/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class GraphContainerTableViewCell: UITableViewCell {

    @IBOutlet weak var graphCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
