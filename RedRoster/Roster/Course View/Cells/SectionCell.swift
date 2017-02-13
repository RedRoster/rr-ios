//
//  SectionCell.swift
//  RedRoster
//
//  Created by Daniel Li on 3/25/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class SectionCell: UITableViewCell {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var classNumberLabel: UILabel!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var locationIcon: UIImageView!
    
    func configure(_ section: Section, selected: Bool, conflicted: Bool = false) {
        backgroundColor = selected ? UIColor.white : UIColor.rosterCellBackgroundColor()
        
        sectionLabel.text = "\(section.sectionType.rawValue) \(section.sectionNumber)"
        sectionLabel.textColor = selected ? UIColor.rosterIconColor() : UIColor.darkGray
        
        classNumberLabel.text = "# \(section.classNumber)"
        classNumberLabel.textColor = UIColor.gray
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        if section.startTime != .unixTime && section.endTime != .unixTime {
            meetingLabel.text = section.daysString + " " + formatter.string(from: section.startTime as Date) + " — " + formatter.string(from: section.endTime as Date)
            meetingLabel.textColor = conflicted ? UIColor.rosterIconColor() : UIColor.darkGray
            timeIcon.image = UIImage(named: "clock")
            timeIcon.tintColor = conflicted ? UIColor.rosterIconColor() : UIColor.darkGray
        } else {
            meetingLabel.text = "Not applicable"
            meetingLabel.textColor = UIColor.gray
            timeIcon.image = UIImage(named: "clock")
            timeIcon.tintColor = UIColor.gray
        }
        
        if !section.location.isEmpty {
            locationLabel.text =  section.location
            locationLabel.textColor = UIColor.darkGray
            locationIcon.image = UIImage(named: "marker")
            locationIcon.tintColor = UIColor.darkGray
        } else {
            locationLabel.text = section.location.isEmpty ? "Not applicable" : section.location
            locationLabel.textColor = UIColor.gray
            locationIcon.image = UIImage(named: "marker")
            locationIcon.tintColor = UIColor.gray
        }
        
    }
    
}
