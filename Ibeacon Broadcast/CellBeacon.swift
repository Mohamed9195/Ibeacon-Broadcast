//
//  CellBeacon.swift
//  Ibeacon Broadcast
//
//  Created by mohamed hashem on 10/16/19.
//  Copyright © 2019 mohamed hashem. All rights reserved.
//

import UIKit

class CellBeacon: UITableViewCell {

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var mijorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
