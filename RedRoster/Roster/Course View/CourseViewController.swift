//
//  CourseViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/28/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import RealmSwift

enum CourseViewOrigin {
    case normal
    case fromSearch(result: CourseResult)
    case fromSchedule
    case fromProfile
}

class CourseViewController: RosterViewController {
    
    var origin: CourseViewOrigin = .normal
    
    // MARK: - Data
    
    var course: Course?
    var users: [User] = []
    var enrollGroups: [Int] = []
    var enrollGroupDict: [Int : [Section]] = [:]
    
    // MARK: - Views
    
    var selectedIndexPaths: Set<IndexPath>?
    var originalSelectedIndexPaths: [IndexPath]?
    var bottomButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        setupTableView()
        
        if case let .fromSearch(result) = origin {
            title = result.shortHand
        } else {
            title = course?.shortHand
        }
        
        if case .fromProfile = origin {
            let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(profileDoneButtonPressed))
            navigationItem.leftBarButtonItem = doneBarButtonItem
        }
        
        if schedule == nil {
            let addToScheduleButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToScheduleButtonPressed))
            navigationItem.rightBarButtonItem = addToScheduleButton
        }
        
        fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.schedule != nil {
            self.setupToolbar()
            self.updateToolbar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setToolbarHidden(true, animated: true)
        setToolbarEnabled(false)
    }
    
    override func fetch() {
        if course?.availableSections.isEmpty ?? true {
            setupActivityIndicator()
            tableView.alpha = 0.0
        } else {
            if let sections = course?.availableSections {
                setupNotification(sections)
            }
        }
        if case let .fromSearch(result) = origin {
            NetworkManager.fetchCourse(inTermWithSlug: result.termSlug, forSubject: result.subject, withNumber: result.number) { users, error in
                let realm = try! Realm()
                realm.refresh()
                if let error = error { self.alert(errorMessage: error.localizedDescription, completion: nil) }
                if let users = users { self.users = users }
                if let course = realm.object(ofType: Course.self, forPrimaryKey: "\(result.id)-\(result.offerNumber)") {
                    self.course = course
                    self.setupNotification(course.availableSections)
                }
                self.activityIndicator?.removeFromSuperview()
            }
        } else {
            guard let course = course else { return }
            NetworkManager.fetchCourse(inTermWithSlug: course.activeTermSlug, forSubject: course.activeSubjectAbbreviation, withNumber: course.activeCourseNumber) { users, error in
                let realm = try! Realm()
                realm.refresh()
                if let error = error { self.alert(errorMessage: error.localizedDescription, completion: nil) }
                if let users = users { self.users = users }
                if let course = try! Realm().object(ofType: Course.self, forPrimaryKey: self.course?.id) {
                    self.course = course
                    self.setupNotification(course.availableSections)
                }
                self.activityIndicator?.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Setup Views
    
    func setupToolbar() {
        
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomButton = UIBarButtonItem(title: (originalSelectedIndexPaths?.isEmpty ?? true) ? "Add Course" : "Update Course", style: .done, target: self, action: #selector(bottomButtonPressed))
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolbarButtons: [UIBarButtonItem] = [leftSpace, bottomButton!, rightSpace]
        
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.setItems(toolbarButtons, animated: true)
        navigationController?.toolbar.isTranslucent = false
        setToolbarEnabled(false)
        
    }
    
    override func setupActivityIndicator() {
        super.setupActivityIndicator()
        guard let activityIndicator = activityIndicator else { return }
        activityIndicator.center = CGPoint(x: tableView.bounds.width / 2, y: tableView.bounds.height / 2)
        activityIndicator.tintColor = UIColor.darkGray
        view.addSubview(activityIndicator)
    }
    
    override func setupTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.autoresizingMask = .flexibleHeight
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.backgroundColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "DetailCell")
        tableView.register(UINib(nibName: "SectionCell", bundle: nil), forCellReuseIdentifier: "SectionCell")
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableView.contentOffset = CGPoint(x: 0, y: 1)
        tableView.contentInset.bottom = 44.0
    }
    
    override func configureTableView() {
        enrollGroupDict.removeAll(keepingCapacity: true)
        
        // Populate dictionary
        course?.availableSections.forEach { section in
            if enrollGroupDict[section.enrollGroup] == nil {
                enrollGroupDict[section.enrollGroup] = [section]
            } else {
                enrollGroupDict[section.enrollGroup]?.append(section)
            }
        }
        
        for enrollGroup in enrollGroupDict.keys {
            enrollGroupDict[enrollGroup]?.sort {
                $0.classNumber < $1.classNumber
            }
        }
        
        enrollGroups = Array(enrollGroupDict.keys).sorted()
        
        if schedule != nil {
            selectedIndexPaths = []
            originalSelectedIndexPaths = []
            
            schedule?.elements
                .filter { $0.courseId == self.course?.courseId }
                .forEach { element in
                    if let section = element.section,
                        let indexPath = indexPathForSection(section) {
                        selectedIndexPaths?.insert(indexPath)
                    }
            }
            originalSelectedIndexPaths?.removeAll()
            originalSelectedIndexPaths?.append(contentsOf: selectedIndexPaths ?? [])
            
            setupToolbar()
            updateToolbar()
        }
        
        tableView.reloadData()
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.alpha = 1.0
        }) 
    }
    
    // MARK: - Selectors and Updates
    
    func profileDoneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func bottomButtonPressed() {
        view.isUserInteractionEnabled = false
        setToolbarEnabled(false)
        guard let classNumbers: [Int] = selectedIndexPaths?.flatMap({ sectionForIndexPath($0)?.classNumber }),
            let course = course,
            let schedule = schedule else { return }
        if let originalNumbers: [Int] = originalSelectedIndexPaths?.flatMap({ sectionForIndexPath($0)?.classNumber }) {
            NetworkManager.deleteElements(schedule, elementsWithIds: schedule.elements.filter { originalNumbers.contains($0.section!.classNumber) }.map { $0.id }) { error in
                if error == nil {
                    NetworkManager.postCourse(schedule, course: course, classNumbers: classNumbers) { error in
                        if let error = error {
                            self.view.isUserInteractionEnabled = true
                            self.setToolbarEnabled(true)
                            self.alert(errorMessage: error.localizedDescription, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            NetworkManager.postCourse(schedule, course: course, classNumbers: classNumbers) { error in
                if let error = error {
                    self.view.isUserInteractionEnabled = true
                    self.setToolbarEnabled(true)
                    self.alert(errorMessage: error.localizedDescription, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func addToScheduleButtonPressed() {
        guard let id = course?.id,
            let termSlug = course?.activeTermSlug, termSlug != "" else { return }
        let scheduleListViewController = ScheduleListViewController(state: .fromCourseView(id: id, termSlug: termSlug))
        let navigationController = UINavigationController(rootViewController: scheduleListViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func updateToolbar() {
        guard let selectedSectionsTypes = selectedIndexPaths?.flatMap({ sectionForIndexPath($0)?.sectionType }) else { return }
        
        if let selected = selectedIndexPaths,
            let original = originalSelectedIndexPaths {
            let sort: (IndexPath, IndexPath) -> Bool = { $0.row < $1.row }
            if selected.sorted(by: sort) == original.sorted(by: sort) {
                setToolbarEnabled(false)
                return
            }
        }
        
        for sectionType in course?.requiredSectionTypes ?? [] {
            if !selectedSectionsTypes.contains(sectionType) {
                setToolbarEnabled(false)
                return
            }
        }
        setToolbarEnabled(true)
    }
    
    func setToolbarEnabled(_ enabled: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationController?.toolbar.tintColor = enabled ? UIColor.white : UIColor.darkGray
            self.navigationController?.toolbar.barTintColor = enabled ? UIColor.rosterRed() : UIColor.rosterCellBackgroundColor()
            self.bottomButton?.isEnabled = enabled
        }) 
    }
    
}

extension CourseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func sectionForIndexPath(_ indexPath: IndexPath) -> Section? {
        return enrollGroupDict[enrollGroups[indexPath.section - 1]]?[indexPath.row]
    }
    
    func indexPathForSection(_ classSection: Section) -> IndexPath? {
        guard let section = enrollGroups.index(of: classSection.enrollGroup),
            let row = enrollGroupDict[classSection.enrollGroup]?.index(of: classSection) else { return nil }
        return IndexPath(row: row, section: section + 1)
    }
    
    func selectSectionAtIndexPath(_ indexPath: IndexPath) {
        guard let newClassSection = sectionForIndexPath(indexPath),
            var selectedIndexPaths = selectedIndexPaths else { return }
        
        var indexPathsToReload: Set<IndexPath> = [indexPath]
        
        if let previousIndexPathIndex = selectedIndexPaths.index(where: {
            guard let section = sectionForIndexPath($0) else { return false }
            return section.sectionType == newClassSection.sectionType && section.enrollGroup == newClassSection.enrollGroup && section != newClassSection
        }) {
            indexPathsToReload.insert(selectedIndexPaths[previousIndexPathIndex])
            selectedIndexPaths.remove(at: previousIndexPathIndex)
            
            indexPathsToReload.insert(indexPath)
        }
        
        if let index = selectedIndexPaths.index(of: indexPath)  {
            selectedIndexPaths.remove(at: index)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
        
        selectedIndexPaths.forEach { indexPath in
            if sectionForIndexPath(indexPath)?.enrollGroup != newClassSection.enrollGroup {
                selectedIndexPaths.remove(indexPath)
                indexPathsToReload.insert(indexPath)
            }
        }
        
        self.selectedIndexPaths = selectedIndexPaths
        
        tableView.reloadRows(at: Array(indexPathsToReload), with: .automatic)
        
        updateToolbar()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + enrollGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if course == nil {
            return 0
        }
        
        if section == 0 {
            return 4
        }
        
        return enrollGroupDict[enrollGroups[section - 1]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
                let course = self.course!
                cell.titleLabel.text = course.title
                cell.titleLabel.textColor = UIColor.rosterRed()
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                
                cell.gradeLabel.text = course.gradeType.description
                cell.gradeLabel.textColor = UIColor.rosterCellTitleColor()
                
                var credits: String = (course.minCredit == course.maxCredit ? "\(course.maxCredit)" : "\(course.minCredit)-\(course.maxCredit)") + " credit"
                if course.maxCredit != 1 {
                    credits += "s"
                }
                cell.creditsLabel.text = credits
                cell.creditsLabel.textColor = UIColor.gray
                
                cell.backgroundColor = UIColor.rosterCellBackgroundColor()
                cell.selectionStyle = .none
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.configure("Details", icon: UIImage(named: "sheet"), detailTitle: nil)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.configure("Reviews", icon: UIImage(named: "speech"), detailTitle: nil)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.configure("Students", icon: UIImage(named: "person-outline"), detailTitle: nil)
                return cell
            default:
                break
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! SectionCell
        
        let section = sectionForIndexPath(indexPath)!
        cell.configure(section, selected: selectedIndexPaths?.contains(indexPath) ?? false)
        
        if schedule != nil {
            if selectedIndexPaths!.contains(indexPath) {
                cell.accessoryView = nil
                cell.accessoryType = .checkmark
                cell.tintColor = UIColor.rosterIconColor()
            } else {
                let button = UIButton(type: .contactAdd)
                button.tintColor = UIColor.rosterIconColor()
                button.isUserInteractionEnabled = false
                cell.accessoryView = button
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPath.row == 0 ? 150.0 : 44.0
        }
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let classSection = enrollGroupDict[section]?.first, !classSection.topicDescription.isEmpty else { return nil }
        return classSection.topicDescription
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.backgroundView?.backgroundColor = UIColor.clear
        headerView.textLabel?.textColor = UIColor.darkGray
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                let courseDetailsViewController = CourseDetailsViewController()
                courseDetailsViewController.course = course
                navigationController?.pushViewController(courseDetailsViewController, animated: true)
            } else if indexPath.row == 2 {
                if UserSignedIn {
                    let reviewsViewController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
                    reviewsViewController.course = course
                    navigationController?.pushViewController(reviewsViewController, animated: true)
                } else {
                    displaySignInMessage()
                }
            } else if indexPath.row == 3 {
                if UserSignedIn {
                    let peopleViewController = PeopleViewController(searchBase: .users(users))
                    navigationController?.pushViewController(peopleViewController, animated: true)
                } else {
                    displaySignInMessage()
                }
            }
        }
        
        if schedule != nil && indexPath.section > 0 {
            selectSectionAtIndexPath(indexPath)
        }
        
    }
    
}
