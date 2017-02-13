//
//  TermCell.swift
//  RedRoster
//
//  Created by Daniel Li on 3/25/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class TermCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var seasonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
