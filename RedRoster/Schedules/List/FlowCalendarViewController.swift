//
//  FlowCalendarViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 8/6/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift

let Days: [WeekDay] = [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
let MinHour = 8
let MaxHour = 23
let DayLabelsHeight: CGFloat = 44.0

class FlowCalendarViewController: UIViewController {
    
    var schedule: Schedule
    var fromProfile: Bool
    var frame: CGRect
    
    init(schedule: Schedule, fromProfile: Bool = false, frame: CGRect) {
        self.schedule = schedule
        self.fromProfile = fromProfile
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func yPositionForDate(_ date: Date) -> CGFloat {
        let calendar = Calendar.current
        let hour = (calendar as NSCalendar).component(.hour, from: date)
        let minute = (calendar as NSCalendar).component(.minute, from: date)
        return yPositionForTime(hour, minute: minute)
    }
    
    func yPositionForTime(_ hour: Int, minute: Int) -> CGFloat {
        let hourHeight = (frame.height - DayLabelsHeight) / CGFloat(MaxHour - MinHour)
        return CGFloat(hour - MinHour) * hourHeight + CGFloat(minute) * hourHeight / 60.0 + DayLabelsHeight
    }
    
    var token: NotificationToken?
    
    var hourContainer: UIView!
    var calendarView: FlowCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = frame
        
        setupHourLabels()
        setupCalendarView()
        setupGestureRecognizers()
        
        if !fromProfile {
            setupNotification()
        }
    }
    
    func setupHourLabels() {
        hourContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: frame.height))
        hourContainer.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        view.addSubview(hourContainer)
        
        for hour in MinHour...MaxHour {
            let label = UILabel()
            let moddedHour = hour % 12
            label.textColor = UIColor.gray
            label.font = UIFont.systemFont(ofSize: 10.0)
            label.textAlignment = .right
            label.text = String(moddedHour == 0 ? 12 : moddedHour)
            label.frame.size = CGSize(width: hourContainer.frame.width - 2.0, height: 16.0)
            label.center.y = yPositionForTime(hour, minute: 0)
            hourContainer.addSubview(label)
            
            let line = UIView(frame: CGRect(x: hourContainer.frame.width, y: yPositionForTime(hour, minute: 0), width: view.frame.width, height: 0.5))
            line.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            view.addSubview(line)
        }
    }
    
    func setupCalendarView() {
        calendarView = FlowCalendarView(frame: CGRect(x: hourContainer.frame.width, y: 0.0, width: view.frame.width - hourContainer.frame.width, height: frame.height), schedule: schedule)
        view.addSubview(calendarView)
    }
    
    func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(controlViewPanned(_:)))
        view.addGestureRecognizer(panGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(controlViewPanned(_:)))
        longPressGesture.minimumPressDuration = 0.0
        view.addGestureRecognizer(longPressGesture)
    }
    
    func setupNotification() {
        token = schedule.elements.addNotificationBlock { [weak self] changes in
            self?.calendarView.reloadData()
        }
    }
    
    func controlViewPanned(_ gesture: UIGestureRecognizer) {
        let index = Int(7 * gesture.location(in: view).x / view.frame.width)
        calendarView.expand(atIndex: index)
        if gesture.state == .ended {
            calendarView.reset()
        }
    }

}
