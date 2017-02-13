//
//  FlowCalendarView.swift
//  RedRoster
//
//  Created by Daniel Li on 8/6/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class FlowCalendarView: UIView {

    fileprivate let MinimizedWidth: CGFloat = 16.0
    
    fileprivate var ExpandedWidth: CGFloat {
        return frame.width - CGFloat(Days.count - 1) * MinimizedWidth
    }
    
    var DayWidth: CGFloat {
        return frame.width / CGFloat(Days.count)
    }
    
    var schedule: Schedule
    var dayViews: [DayView] = []
    
    init(frame: CGRect, schedule: Schedule) {
        self.schedule = schedule
        super.init(frame: frame)
        
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        dayViews.forEach { $0.removeFromSuperview() }
        dayViews = Days.enumerated().map { index, day in
            let dayView = DayView(frame: CGRect(x: CGFloat(index) * DayWidth, y: 0.0, width: DayWidth, height: frame.size.height), day: day, schedule: schedule)
            
            addSubview(dayView)
            return dayView
        }
    }
    
    func expand(atIndex index: Int) {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            for (dayIndex, dayView) in self.dayViews.enumerated() {
                switch dayIndex {
                case 0..<index:
                    dayView.frame.origin.x = CGFloat(dayIndex) * self.MinimizedWidth
                    dayView.frame.size.width = self.MinimizedWidth
                    dayView.contract()
                case index:
                    dayView.frame.origin.x = CGFloat(dayIndex) * self.MinimizedWidth
                    dayView.frame.size.width = self.ExpandedWidth
                    dayView.expand()
                case index+1..<Days.count:
                    dayView.frame.origin.x = (CGFloat(dayIndex) - 1) * self.MinimizedWidth + self.ExpandedWidth
                    dayView.frame.size.width = self.MinimizedWidth
                    dayView.contract()
                default:
                    break
                }
            }
        }, completion: nil)
    }
    
    func reset() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            for (index, dayView) in self.dayViews.enumerated() {
                dayView.frame = CGRect(x: CGFloat(index) * self.DayWidth, y: 0.0, width: self.DayWidth, height: self.frame.size.height)
                dayView.reset()
            }
        }, completion: nil)
    }

}

class DayView: UIView {
    
    func yPositionForTime(_ date: Date) -> CGFloat {
        let hourHeight = (frame.height - DayLabelsHeight) / CGFloat(MaxHour - MinHour)
        let calendar = Calendar.current
        let hour = (calendar as NSCalendar).component(.hour, from: date)
        let minute = (calendar as NSCalendar).component(.minute, from: date)
        let height = (CGFloat(hour - MinHour) * hourHeight) + (CGFloat(minute) * hourHeight / 60.0) + DayLabelsHeight
        return height
    }
    
    var dayButton: UIButton!
    
    var day: WeekDay
    var elements: [Element]
    
    var elementViews: [ElementView] = []
    
    init(frame: CGRect, day: WeekDay, schedule: Schedule) {
        self.day = day
        elements = schedule.elements.filter { $0.section?.days.contains(day) ?? false }
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        clipsToBounds = true
        
        dayButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: DayLabelsHeight))
        dayButton.setTitleColor(UIColor.gray, for: UIControlState())
        dayButton.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        dayButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        reset()
        addSubview(dayButton)
        
        for element in elements {
            guard let section = element.section,
                let course = schedule.courses.filter({ $0.courseId == element.courseId }).first else { break }
            let startPosition = yPositionForTime(section.startTime as Date)
            let endPosition = yPositionForTime(section.endTime as Date)
            
            let elementView = ElementView(frame: CGRect(x: 0.0, y: startPosition, width: frame.width, height: endPosition - startPosition), element: element, course: course)
            addSubview(elementView)
            elementViews.append(elementView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expand() {
        setWidths()
        elementViews.forEach { $0.expandTitle() }
        dayButton.setTitle(day.longDescription.uppercased(), for: UIControlState())
    }
    
    func reset() {
        setWidths()
        elementViews.forEach { $0.reset() }
        dayButton.setTitle(day.shortDescription.uppercased(), for: UIControlState())
    }
    
    func contract() {
        setWidths()
        elementViews.forEach { $0.reset() }
        dayButton.setTitle(String(day.shortDescription.characters.first!), for: UIControlState())
    }
    
    fileprivate func setWidths() {
        dayButton.frame.size.width = frame.width
        elementViews.forEach { $0.frame.size.width = frame.width }
    }
}

class ElementView: UIView {
    
    var element: Element
    var course: Course
    
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    
    init(frame: CGRect, element: Element, course: Course) {
        self.element = element
        self.course = course
        super.init(frame: frame)
        
        backgroundColor = (element.collision ? UIColor.red : UIColor.rosterRed()).withAlphaComponent(0.4)
        
        let border = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 2.0, height: frame.height))
        border.backgroundColor = element.collision ? UIColor.red : UIColor.rosterRed()
        addSubview(border)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        
        reset()
        
        addSubview(titleLabel)
    }
    
    func expandTitle() {
        let titleText = NSMutableAttributedString(string: course.shortHand, attributes: [NSForegroundColorAttributeName : UIColor.white])
        titleText.append(NSAttributedString(string: " \(element.section!.sectionType.rawValue) \(element.section!.sectionNumber)", attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.75)]))
        
        titleLabel.attributedText = titleText
        titleLabel.frame = CGRect(x: 4.0, y: 4.0, width: frame.width - 8.0, height: 14.0)
    }
    
    func reset() {
        titleLabel.frame = CGRect(x: 4.0, y: 4.0, width: frame.width - 8.0, height: 14.0)
        titleLabel.text = course.shortHand
        titleLabel.textColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
