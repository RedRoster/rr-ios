//
//  CourseDetailsViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/30/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class CourseDetailsViewController: UIViewController {

    var tableView: UITableView!
    var course: Course!
    
    var sections: [String] = []
    var sectionsDict: [String : [NSMutableAttributedString]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        setupData()
        setupTableView()
        
    }
    
    func setupData() {
        if !course.courseDescription.isEmpty {
            let title = "Course Description"
            sectionsDict[title] = [NSMutableAttributedString(string: course.courseDescription)]
            sections.append(title)
        }
        
        if !course.crosslistings.isEmpty {
            let title = "Cross Listings"
            sectionsDict[title] = course.crosslistings.map { NSMutableAttributedString(string: $0.shortHand) }
            sections.append(title)
        }
        
        if !course.prerequisitesString.isEmpty {
            let title = "Prerequisites"
            sectionsDict[title] = [NSMutableAttributedString(string: course.prerequisitesString)]
            sections.append(title)
        }
        
//        if let instructors = course.availableSections
//            .flatMap({ $0.instructors })
//            .flatMap({ $0 })
//            where !instructors.isEmpty {
//            let title = "Instructors"
//            var instructorSet: [Instructor] = []
//            
//            for instructor in instructors {
//                if !instructorSet.contains({ $0.netID == instructor.netID }) {
//                    instructorSet.append(instructor)
//                }
//            }
//            
//            sectionsDict[title] = instructorSet.map {
//                let string = NSMutableAttributedString(string: $0.name, attributes: [NSForegroundColorAttributeName : UIColor.rosterCellTitleColor()])
//                string.appendAttributedString(NSMutableAttributedString(string: " " + $0.netID, attributes: [NSForegroundColorAttributeName : UIColor.rosterCellSubtitleColor()]))
//                return string
//            }
//            
//            sections.append(title)
//        }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.autoresizingMask = .flexibleHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CourseDetailCell", bundle: nil), forCellReuseIdentifier: "CourseDetailCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        
        view.addSubview(tableView)
    }
}

extension CourseDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsDict[sections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseDetailCell", for: indexPath) as! CourseDetailCell
        let attributedText = sectionsDict[sections[indexPath.section]]![indexPath.row]
        attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.rosterCellTitleColor(), range: NSRange(location: 0, length: attributedText.length))
        cell.contentLabel.attributedText = attributedText
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
}
