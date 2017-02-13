//
//  ScheduleCell.swift
//  RedRoster
//
//  Created by Daniel Li on 4/7/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    
    @IBOutlet weak var coursesLabel: UILabel!
    @IBOutlet weak var publicIcon: UIImageView!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var publicIndicator: UIView!
    @IBOutlet weak var conflictLabel: UILabel!
    
    func configure(_ schedule: Schedule) {
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
        
        nameLabel.text = schedule.name
        nameLabel.textColor = UIColor.rosterCellTitleColor()
        
        coursesLabel.text = "\(schedule.courses.count) course"
        if schedule.courses.count != 1 { coursesLabel.text = coursesLabel.text! + "s" }
        coursesLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        creditsLabel.text = (schedule.minCredits == schedule.maxCredits ? "\(schedule.maxCredits)" : "\(schedule.minCredits)-\(schedule.maxCredits)") + " Credits"
        creditsLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        publicIcon.isHidden = !schedule.active
        publicIcon.tintColor = UIColor.rosterRed()
        publicIcon.backgroundColor = nil
        
        publicLabel.isHidden = !schedule.active
        publicLabel.textColor = UIColor.rosterRed()
        
        publicIndicator.isHidden = !schedule.active
        publicIndicator.backgroundColor = UIColor.rosterRed()
        
        conflictLabel.isHidden = !schedule.conflicted
    }
    
}
