//
//  ScheduleListViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 4/6/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift
import DGActivityIndicatorView

class ScheduleListViewController: UIViewController {
    
    enum State {
        case normal
        case fromCourseView(id: String, termSlug: String)
    }
    
    var state: State = .normal
    
    init(state: State = .normal) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var schedules: Results<Schedule> = try! Realm().objects(Schedule.self)
    var schedulesDict: [String:[Schedule]] = [:]
    var terms: [Term] = []
    
    var tableView: UITableView!
    var emptyLabel: UILabel!
    var activityIndicator: DGActivityIndicatorView!
    var newButton: UIBarButtonItem?
    
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case .normal = state {
            title = "Schedules"
        } else {
            title = "Choose Schedule"
        }
        
        navigationController?.setTheme()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        setupBarButtons()
        setupTableView()
        setupActivityIndicator()
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.startAnimating()
        tableView.reloadData()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func setupNotification() {
        token = schedules.addNotificationBlock { [weak self] changes in
            self?.configureTableView()
        }
    }
    
    func setupBarButtons() {
        if case .normal = state {
            newButton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(newButtonPressed))
            navigationItem.rightBarButtonItem = newButton
        } else {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        
        tableView.backgroundColor = UIColor.rosterBackgroundColor()
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.alpha = 0.0
        tableView.rowHeight = 88.0
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        emptyLabel = UILabel(frame: view.frame)
        emptyLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let placeholder = NSMutableAttributedString(string: "No Schedules Yet!", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24.0)])
        placeholder.append(NSMutableAttributedString(string: "\n\nCreate one with the 'New' button.", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)]))
        
        emptyLabel.attributedText = placeholder
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.numberOfLines = 3
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        
        view.addSubview(emptyLabel)
    }
    
    func setupActivityIndicator() {
        activityIndicator = DGActivityIndicatorView(type: .threeDots, tintColor: UIColor.darkGray)
        activityIndicator.center = CGPoint(x: tableView.bounds.width / 2, y: tableView.bounds.height / 2)
        activityIndicator.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(activityIndicator)
    }
    
    func retryButtonPressed(_ sender: UIButton) {
        setupActivityIndicator()
        activityIndicator.startAnimating()
        fetch()
    }
    
    func newButtonPressed() {
        let newScheduleViewController = NewScheduleViewController()
        let navigationController = UINavigationController(rootViewController: newScheduleViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetch() {
        setupNotification()
        NetworkManager.fetchSchedules(forUserWithid: User.currentUser.id, readOnly: false) { _, error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription) { Void in
                    self.activityIndicator.fadeRemoveFromSuperView()
                }
            } else {
                self.newButton?.isEnabled = true
            }
        }
    }
    
    func configureTableView() {
        schedulesDict.removeAll()
        
        for schedule in schedules {
            guard let termSlug = schedule.term?.slug else { continue }
            if case let .fromCourseView(_, term) = state {
                if term != termSlug { continue }
            }
            if schedulesDict[termSlug] == nil {
                schedulesDict[termSlug] = [schedule]
            } else {
                if schedule.active {
                    schedulesDict[termSlug]?.insert(schedule, at: 0)
                } else {
                    schedulesDict[termSlug]?.append(schedule)
                }
            }
            schedulesDict[termSlug]?.sort {
                if $0.active { return true }
                if $1.active { return false }
                return $0.creationDate.timeIntervalSince1970 < $1.creationDate.timeIntervalSince1970
            }
        }
        
        terms = schedulesDict.keys.map { Term.create($0) }
        terms.sort {
            if $0.year > $1.year { return true }
            else if $0.year == $1.year && $0.season.sortIndex < $1.season.sortIndex { return true }
            else { return false }
        }
        activityIndicator.removeFromSuperview()
        tableView.reloadData()
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 1.0
        }) 
        
        if terms.count == 0 {
            tableView.isScrollEnabled = false
            emptyLabel.isHidden = false
        } else {
            tableView.isScrollEnabled = true
            emptyLabel.fadeHide()
        }
    }
}

extension ScheduleListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return terms.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedulesDict[terms[section].slug]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let schedule = schedulesDict[terms[indexPath.section].slug]![indexPath.row]
        
        cell.configure(schedule)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if case let .fromCourseView(id, _) = state {
            if let scheduleId = schedulesDict[terms[indexPath.section].slug]?[indexPath.row].id {
                let realm = try! Realm()
                let courseViewController = CourseViewController()
                courseViewController.course = realm.object(ofType: Course.self, forPrimaryKey: id)
                courseViewController.schedule = realm.object(ofType: Schedule.self, forPrimaryKey: scheduleId)
                navigationController?.pushViewController(courseViewController, animated: true)
            }
        } else {
            let scheduleViewController = ScheduleViewController(schedule: schedulesDict[terms[indexPath.section].slug]![indexPath.row])
            navigationController?.pushViewController(scheduleViewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(terms[section].description)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.rosterHeaderTitleColor()
        header.backgroundView?.backgroundColor = UIColor.rosterHeaderColor()
    }
}
