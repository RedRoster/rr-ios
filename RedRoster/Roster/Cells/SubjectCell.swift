//
//  SubjectCell.swift
//  RedRoster
//
//  Created by Daniel Li on 3/27/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class SubjectCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var abbreviationLabel: UILabel!
    
    func configure(_ subject: Subject) {
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        nameLabel.text = subject.name
        nameLabel.textColor = UIColor.rosterCellTitleColor()
        
        abbreviationLabel.text = subject.abbreviation
        abbreviationLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
    }
    
}
