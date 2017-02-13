//
//  ScheduleTableViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 8/6/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleTableViewController: UIViewController {
    
    var schedule: Schedule!
    var courses: [Course] = []
    var sectionDict: [Course : [Element]] = [:]
    var token: NotificationToken?
    
    var redView: UIView!
    var scheduleView: ScheduleInfoView!
    var tableView: UITableView!
    var emptyLabel: UILabel!
    
    let ScheduleViewHeight: CGFloat = 50.0
    var frame: CGRect
    var fromProfile: Bool
    
    init(schedule: Schedule, fromProfile: Bool = false, frame: CGRect) {
        self.schedule = schedule
        self.fromProfile = fromProfile
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = schedule.name
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        view.frame = frame
        
        setupTableView()
        setupScheduleView()
        configureTableView()
        checkEmpty()
        
        if !fromProfile {
            setupNotification()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        scheduleView.alpha = 1.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIView.animate(withDuration: 0.35, animations: {
            self.scheduleView.alpha = 0.0
        }) 
    }
    
    func configureTableView() {
        sectionDict.removeAll(keepingCapacity: true)
        var elements = Array(schedule.elements.filter { $0.section != nil })
        courses = Array(schedule.courses)
        
        for course in courses {
            while let index = elements.index(where: { $0.courseId == course.courseId }) {
                let element = elements.remove(at: index)
                
                if sectionDict[course] != nil {
                    sectionDict[course]?.append(element)
                } else {
                    sectionDict[course] = [element]
                }
                
                sectionDict[course]?.sort { $0.section?.classNumber ?? 0 < $1.section?.classNumber ?? 0 }
            }
        }
        
//        courses.sort { sectionDict[$0]?.first?.creationDate.timeIntervalSince1970 < sectionDict[$1]?.first?.creationDate.timeIntervalSince1970 }
        courses.sort { sectionDict[$0]?.first?.creationDate.timeIntervalSince1970 ?? 0 < sectionDict[$1]?.first?.creationDate.timeIntervalSince1970 ?? 0 }
        
        tableView.reloadData()
    }
    
    func setupNotification() {
        token = schedule.elements.addNotificationBlock { [weak self] changes in
            self?.configureTableView()
            self?.scheduleView.updateInfo()
            self?.checkEmpty()
        }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "SectionCell", bundle: nil), forCellReuseIdentifier: "SectionCell")
        tableView.register(UINib(nibName: "DeleteCell", bundle: nil), forCellReuseIdentifier: "DeleteCell")
        let footer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 66.0))
        footer.backgroundColor = UIColor.clear
        tableView.tableFooterView = footer
        
        view.addSubview(tableView)
        
        emptyLabel = UILabel(frame: view.frame)
        emptyLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        emptyLabel.text = "No Courses"
        emptyLabel.font = UIFont.systemFont(ofSize: 24.0)
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.numberOfLines = 2
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        
        view.addSubview(emptyLabel)
    }
    
    func setupScheduleView() {
        redView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: ScheduleViewHeight))
        redView.backgroundColor = UIColor.rosterRed()
        view.insertSubview(redView, belowSubview: tableView)
        
        scheduleView = ScheduleInfoView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: ScheduleViewHeight), schedule: schedule)
        scheduleView.updateInfo()
        tableView.tableHeaderView = scheduleView
    }
    
    func checkEmpty() {
        if schedule.courses.isEmpty {
            emptyLabel.fadeShow()
            tableView.isScrollEnabled = false
        } else {
            emptyLabel.fadeHide()
            tableView.isScrollEnabled = true
        }
    }
}

extension ScheduleTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionDict[courses[section]]?.count ?? 0) + (fromProfile ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elements = sectionDict[courses[indexPath.section]]!
        
        if indexPath.row == elements.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath) as! DeleteCell
            
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            cell.selectionStyle = .default
            
            let view = UIView()
            view.backgroundColor = UIColor.rosterCellSelectionColor()
            cell.selectedBackgroundView = view
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! SectionCell
        
        let element = elements[indexPath.row]
        cell.configure(element.section!, selected: false, conflicted: element.collision)
        let view = UIView()
        view.backgroundColor = UIColor.rosterCellBackgroundColor()
        cell.selectedBackgroundView = view
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == sectionDict[courses[indexPath.section]]!.count { return 44.0 }
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let courseId = courses[indexPath.section]
        
        if indexPath.row == sectionDict[courseId]!.count {
            deleteCellTapped(courseId)
        } else {
            presentCourseViewController(courseId)
        }
    }
    
    // MARK: - Header
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let course = courses[section]
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 66.0))
        header.tag = section
        header.backgroundColor = UIColor.rosterBackgroundColor()
        
        let shortHandLabel = UILabel(frame: CGRect(x: 0.0, y: 12.0, width: header.frame.width, height: header.frame.height / 3))
        shortHandLabel.text = course.shortHand 
        shortHandLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        shortHandLabel.textColor = UIColor.rosterHeaderTitleColor()
        shortHandLabel.textAlignment = .center
        header.addSubview(shortHandLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: 8.0, y: shortHandLabel.frame.maxY, width: header.frame.width - 16.0, height: header.frame.height - shortHandLabel.frame.maxY - 12.0))
        titleLabel.text = course.title
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        header.addSubview(titleLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        header.addGestureRecognizer(tapGesture)
        
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scheduleView.alpha = (-1/20) * scrollView.contentOffset.y + 1
        redView.frame.size.height = max(-scrollView.contentOffset.y + ScheduleViewHeight, 0.0)
    }
}

// MARK: - Selectors

extension ScheduleTableViewController {
    
    func deleteCellTapped(_ course: Course) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if !fromProfile {
            let removeAction = UIAlertAction(title: "Remove \(course.shortHand)", style: .destructive) { Void in
                let ids = self.schedule.elements.filter { $0.courseId == course.courseId }.map { $0.id }
                NetworkManager.deleteElements(self.schedule, elementsWithIds: Array(ids)) { error in
                    if let error = error {
                        self.alert(errorMessage: error.localizedDescription, completion: nil)
                        return
                    }
                }
            }
            alertController.addAction(removeAction)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        presentCourseViewController(courses[section])
    }
    
    func presentCourseViewController(_ course: Course) {
        let courseViewController = CourseViewController()
        courseViewController.course = course
        courseViewController.schedule = fromProfile ? nil : schedule
        courseViewController.origin = fromProfile ? .fromProfile : .normal
        let navigationController = UINavigationController(rootViewController: courseViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}
