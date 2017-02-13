//
//  CourseCell.swift
//  RedRoster
//
//  Created by Daniel Li on 3/25/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var peopleicon: UIImageView!
    
    func configure(_ course: Course) {
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        numberLabel.text = course.shortHand
        numberLabel.textColor = UIColor.rosterCellTitleColor()
        
        titleLabel.text = course.title
        titleLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        peopleicon.image = nil
        peopleLabel.text = ""
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
    }
    
    func configure(_ result: CourseResult) {
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        numberLabel.text = result.shortHand
        numberLabel.textColor = UIColor.rosterCellTitleColor()
        
        titleLabel.text = result.title
        titleLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        peopleicon.image = nil
        peopleLabel.text = ""
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
    }
}
