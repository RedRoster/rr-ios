//
//  SubjectViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/28/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class SubjectViewController: RosterViewController, UITableViewDataSource, UITableViewDelegate {
    
    var subject: Subject!
    var filteredCourses: [Course] = []
    
    var searchField: SearchTextField!
    var searchLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = subject.abbreviation + " Courses"
        
        setupTableView()
        setupSearchField()
        fetch()
    }
    
    func setupSearchField() {
        searchField = SearchTextField(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 44.0))
        searchField.autoresizingMask = [.flexibleWidth]
        searchField.leftMargin = 16.0
        searchField.rightMargin = 16.0
        
        searchField.delegate = self
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .always
        
        searchField.alpha = 0.0
        searchField.backgroundColor = UIColor.rosterSearchBackgroundColor()
        searchField.textColor = UIColor.darkGray
        searchField.font = UIFont.systemFont(ofSize: 14.0)
        let placeholder = NSAttributedString(string: "Search courses by number or title", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)])
        searchField.attributedPlaceholder = placeholder
        
        searchField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let border = UIView(frame: CGRect(x: 0.0, y: searchField.frame.height - 1.0, width: searchField.frame.width, height: 1.0))
        border.backgroundColor = UIColor.rosterBackgroundColor()
        border.autoresizingMask = .flexibleWidth
        searchField.addSubview(border)
        
        view.addSubview(searchField)
        
        tableView.contentInset = UIEdgeInsets(top: searchField.frame.size.height, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: searchField.frame.size.height, left: 0, bottom: 0, right: 0)
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CourseCell", bundle: nil), forCellReuseIdentifier: "CourseCell")
        tableView.rowHeight = 77.0
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.indicatorStyle = .black
        tableView.keyboardDismissMode = .onDrag
        
        searchLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.width, height: 44.0))
        searchLabel.text = ""
        searchLabel.textColor = UIColor.rosterCellSubtitleColor()
        searchLabel.textAlignment = .center
        searchLabel.font = UIFont.systemFont(ofSize: 14.0)
        tableView.tableFooterView = searchLabel
    }
    
    override func fetch() {
        if subject.courses.isEmpty {
            setupActivityIndicator()
            tableView.alpha = 0.0
        }
        setupNotification(subject.courses)
        NetworkManager.fetchCourses(subjectWithId: subject.id, andAbbreviation: subject.abbreviation, termSlug: subject.term?.slug ?? "") { error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription, completion: nil)
            }
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    override func configureTableView() {
        if !subject.courses.isEmpty {
            tableView.reloadData()
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.alpha = 1.0
                self.searchField.alpha = 1.0
            }) 
        }
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchField.text != "" ? filteredCourses.count : subject.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCell
        let course = searchField.text != "" ? filteredCourses[indexPath.row] : subject.courses[indexPath.row]
        
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        
        let subjectString = NSMutableAttributedString(string: "\(subject.abbreviation)", attributes: [NSForegroundColorAttributeName : UIColor.rosterRed()])
        let numberString = NSMutableAttributedString(string: " \(course.activeCourseNumber)", attributes: [NSForegroundColorAttributeName : UIColor.rosterCellTitleColor()])
        subjectString.append(numberString)
        cell.numberLabel.attributedText = subjectString
        
        cell.titleLabel.text = course.title
        cell.titleLabel.textColor = UIColor.rosterCellSubtitleColor()
        cell.titleLabel.sizeToFit()
        
//        cell.peopleicon.image = UIImage(named: "person")
//        cell.peopleicon.tintColor = UIColor.grayColor()
//        cell.peopleLabel.text = String(course.users.count)
//        cell.peopleLabel.textColor = UIColor.grayColor()
        cell.peopleicon.isHidden = true
        cell.peopleLabel.isHidden = true
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        cell.selectedBackgroundView = background
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let courseViewController = CourseViewController()
        courseViewController.course = searchField.text != "" ? filteredCourses[indexPath.row] : subject.courses[indexPath.row]
        courseViewController.schedule = schedule
        navigationController?.pushViewController(courseViewController, animated: true)
    }
    
    // MARK: - Search
    
    func filterTableView(forQuery query: String) {
        if query != "" {
            filteredCourses = subject.courses.filter {
                return $0.title.range(of: query, options: [.caseInsensitive]) != nil
                    || $0.shortHand.range(of: query, options: [.caseInsensitive]) != nil
            }
            if filteredCourses.count == 0 {
                searchLabel.text = "No courses match your search."
            } else {
                searchLabel.text = ""
            }
        } else {
            searchLabel.text = ""
        }
        tableView.reloadData()
        
    }
}

extension SubjectViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filterTableView(forQuery: "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldChanged() {
        filterTableView(forQuery: searchField.text ?? "")
    }
}
