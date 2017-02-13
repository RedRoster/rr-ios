//
//  SubjectsViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/27/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class SubjectsViewController: RosterViewController, UITableViewDelegate, UITableViewDataSource {
    
    var term: Term!
    
    var subjectsDict: [Character : [Subject]] = [:]
    var letters: [Character] = []
    var filteredItems: ([Subject], [CourseResult]) = ([], [])
    
    var searchLabel: UILabel!
    var searchField: SearchTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = term.description
        
        setupTableView()
        setupSearchField()
        fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !query.isEmpty {
            searchCourses()
        }
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
        let placeholder = NSAttributedString(string: "Search roster (e.g. AGSCI, CHEM 2090)", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)])
        searchField.attributedPlaceholder = placeholder
        
        searchField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        view.addSubview(searchField)
        
        tableView.contentInset.top = searchField.frame.size.height
        tableView.scrollIndicatorInsets.top = searchField.frame.size.height
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SubjectCell", bundle: nil), forCellReuseIdentifier: "SubjectCell")
        tableView.register(UINib(nibName: "CourseCell", bundle: nil), forCellReuseIdentifier: "CourseCell")
        tableView.rowHeight = 52.0
        
        tableView.alpha = 0.0
        tableView.sectionIndexColor = UIColor.darkGray
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.rosterHeaderColor()
        tableView.keyboardDismissMode = .onDrag
        
        searchLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.width, height: 44.0))
        searchLabel.text = ""
        searchLabel.textColor = UIColor.rosterCellSubtitleColor()
        searchLabel.textAlignment = .center
        searchLabel.font = UIFont.systemFont(ofSize: 14.0)
        tableView.tableFooterView = searchLabel
    }
    
    override func fetch() {
        if term.subjects.isEmpty {
            setupActivityIndicator()
        }
        
        setupNotification(term.subjects)
        
        NetworkManager.fetchSubjects(termWithSlug: term.slug) { error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription, completion: nil)
            }
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    override func configureTableView() {
        if !term.subjects.isEmpty {
            subjectsDict.removeAll()
            
            for subject in term.subjects {
                let startChar = subject.abbreviation.characters[subject.abbreviation.startIndex]
                if subjectsDict[startChar] == nil {
                    subjectsDict[startChar] = [subject]
                } else {
                    subjectsDict[startChar]?.append(subject)
                }
            }
            
            letters = subjectsDict.keys.sorted()
            
            tableView.reloadData()
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.alpha = 1.0
                self.searchField.alpha = 1.0
            }) 
        }
    }
    
    // MARK: TableView Delegate and DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchField.text != "" {
            return filteredItems.0.isEmpty ? 1 : 2
        }
        return letters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchField.text != "" {
            if filteredItems.0.isEmpty {
                return filteredItems.1.count
            }
            return section == 0 ? filteredItems.0.count : filteredItems.1.count
        }
        return subjectsDict[letters[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchField.text != "" {
            if filteredItems.0.isEmpty || indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCell
                let course = filteredItems.1[indexPath.row]
                
                cell.configure(course)
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
            let subject = filteredItems.0[indexPath.row]
            
            cell.configure(subject)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
        let letter = letters[indexPath.section]
        let subject = subjectsDict[letter]![indexPath.row]
        
        cell.configure(subject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if searchField.text != "" {
            if filteredItems.0.isEmpty || indexPath.section == 1 {
                let courseViewController = CourseViewController()
                courseViewController.origin = CourseViewOrigin.fromSearch(result: filteredItems.1[indexPath.row])
                courseViewController.schedule = schedule
                navigationController?.pushViewController(courseViewController, animated: true)
                return
            }
            let subjectViewController = SubjectViewController()
            subjectViewController.subject = filteredItems.0[indexPath.row]
            subjectViewController.schedule = schedule
            navigationController?.pushViewController(subjectViewController, animated: true)
            return
        }
        
        let subjectViewController = SubjectViewController()
        subjectViewController.subject = subjectsDict[letters[indexPath.section]]![indexPath.row]
        subjectViewController.schedule = schedule
        navigationController?.pushViewController(subjectViewController, animated: true)
    }
    
    // MARK: TableView Section Index
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchField.text != "" {
            if filteredItems.0.isEmpty {
                return "COURSES"
            }
            return section == 0 ? "SUBJECTS" : "COURSES"
        }
        return String(letters[section])
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return searchField.text!.isEmpty ? letters.map { String($0) } : nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    // MARK: Search
    
    func filterTableView() {
        searchLabel.text = "Searching..."
        filteredItems = ([],[])
        tableView.reloadData()
        
        if query.isEmpty {
            searchLabel.text = ""
            return
        }
        
        let newQuery = query.alphanumeric().uppercased()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchCourses), object: nil)
        perform(#selector(searchCourses), with: nil, afterDelay: 0.5)
        filteredItems.0 = term.subjects.filter {
            return $0.name.localizedCaseInsensitiveContains(newQuery)
                || $0.abbreviation.localizedCaseInsensitiveContains(newQuery)
        }
        
        tableView.reloadData()
    }
    
    func searchCourses() {
        NetworkManager.searchCourses(term.slug, query: query.alphanumeric().uppercased()) { results in
            if results != nil {
                self.filteredItems.1 = results!
                self.tableView.reloadData()
                self.searchLabel.text = results!.count == 0 ? "No results" : ""
            }
        }
    }
}

extension SubjectsViewController: UITextFieldDelegate {
    var query: String {
        return searchField.text ?? ""
    }
    
    func textFieldChanged(_ sender: UITextField) {
        filterTableView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}


