//
//  ScheduleView.swift
//  RedRoster
//
//  Created by Daniel Li on 5/9/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import UICountingLabel

class ScheduleInfoView: UIView {
    
    let LabelMargin: CGFloat = 8.0
    var LabelSize: CGSize!
    
    let LabelAttributedBlock: (_ main: String, _ sub: String) -> NSAttributedString = { main, subtitle in
        let CountingLabelAttributes: [String : AnyObject] = [NSFontAttributeName : UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName : UIColor.white]
        let CountingLabelSubtitleAttributes: [String : AnyObject] = [NSFontAttributeName : UIFont.systemFont(ofSize: 10.0), NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.7)]
        let string = NSMutableAttributedString(string: main, attributes: CountingLabelAttributes)
        string.append(NSAttributedString(string: "\n\(subtitle)", attributes: CountingLabelSubtitleAttributes))
        return string
    }
    
    var termLabel: UILabel!
    
    var coursesLabel: UICountingLabel!
    var minCreditsLabel: UICountingLabel!
    var maxCreditsLabel: UICountingLabel!
    var hoursLabel: UICountingLabel!
    
    var schedule: Schedule!
    
    func updateInfo() {
        let term = Term.create(schedule.termSlug)
        termLabel.attributedText = LabelAttributedBlock(term.season.description, String(term.year))
            
        coursesLabel.countFromCurrentValue(to: CGFloat(schedule.courses.count), withDuration: CountingLabelAnimationDuration)
        hoursLabel.countFromCurrentValue(to: CGFloat(schedule.hours), withDuration: CountingLabelAnimationDuration)
        minCreditsLabel.countFromCurrentValue(to: CGFloat(schedule.minCredits), withDuration: CountingLabelAnimationDuration)
        maxCreditsLabel.countFromCurrentValue(to: CGFloat(schedule.maxCredits), withDuration: CountingLabelAnimationDuration)
    }
    
    init(frame: CGRect, schedule: Schedule) {
        super.init(frame: frame)
        
        let TermWidth: CGFloat = 60.0
        let HoursWidth: CGFloat = 40.0
        LabelSize = CGSize(width: (frame.width - 2 * LabelMargin - TermWidth - HoursWidth) / 3, height: 30.0)
        
        backgroundColor = UIColor.clear
        
        self.schedule = schedule
        
        termLabel = UILabel(frame: CGRect(x: LabelMargin, y: frame.height - LabelMargin - LabelSize.height, width: TermWidth, height: LabelSize.height))
        termLabel.numberOfLines = 2
        termLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(termLabel)
        
        coursesLabel = UICountingLabel(frame: CGRect(origin: CGPoint(x: termLabel.frame.maxX, y: frame.height - LabelMargin - LabelSize.height), size: LabelSize))
        coursesLabel.attributedFormatBlock = { self.LabelAttributedBlock(String(Int($0)), "COURSES") }
        coursesLabel.numberOfLines = 2
        coursesLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(coursesLabel)
        
        minCreditsLabel = UICountingLabel(frame: CGRect(origin: CGPoint(x: coursesLabel.frame.maxX, y: frame.height - LabelMargin - LabelSize.height), size: LabelSize))
        minCreditsLabel.attributedFormatBlock = { self.LabelAttributedBlock(String(format: "%.1f", $0), "MIN CREDS") }
        minCreditsLabel.numberOfLines = 2
        minCreditsLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(minCreditsLabel)
        
        maxCreditsLabel = UICountingLabel(frame: CGRect(origin: CGPoint(x: minCreditsLabel.frame.maxX, y: frame.height - LabelMargin - LabelSize.height), size: LabelSize))
        maxCreditsLabel.attributedFormatBlock = { self.LabelAttributedBlock(String(format: "%.1f", $0), "MAX CREDS") }
        maxCreditsLabel.numberOfLines = 2
        maxCreditsLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(maxCreditsLabel)
        
        
        hoursLabel = UICountingLabel(frame: CGRect(x: maxCreditsLabel.frame.maxX, y: frame.height - LabelMargin - LabelSize.height, width: HoursWidth, height: LabelSize.height))
        hoursLabel.attributedFormatBlock = { self.LabelAttributedBlock(String(format: "%.1f", $0), "HOURS") }
        hoursLabel.numberOfLines = 2
        hoursLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(hoursLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
