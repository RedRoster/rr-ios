//
//  PeopleViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 4/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import Haneke

class PeopleViewController: UIViewController {

    var tableView: UITableView!
    var searchField: SearchTextField!
    var searchLabel: UILabel!
    var aboutLabel: UILabel!
    
    var filteredUsers: [User] = []
    
    enum PeopleSearchBase {
        case users([User])
        case serverSide
    }
    
    var searchBase: PeopleSearchBase
    
    init(searchBase: PeopleSearchBase) {
        self.searchBase = searchBase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setTheme()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        if case .serverSide = searchBase {
            navigationItem.title = "Search People"
        } else {
            title = "Students"
        }
        setupTableView()
        setupSearchField()
        setupTapGesture()
        filterTableView(forQuery: "")
    }
    
    func setupSearchField() {
        searchField = SearchTextField(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 44.0))
        searchField.autoresizingMask = [.flexibleWidth]
        searchField.leftMargin = 16.0
        searchField.rightMargin = 16.0
        
        searchField.delegate = self
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .always
        
        searchField.backgroundColor = UIColor.rosterSearchBackgroundColor()
        searchField.textColor = UIColor.darkGray
        searchField.font = UIFont.systemFont(ofSize: 14.0)
        let placeholder = NSAttributedString(string: "Name or NetID", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)])
        searchField.attributedPlaceholder = placeholder
        
        searchField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let border = UIView(frame: CGRect(x: 0.0, y: searchField.frame.height - 1.0, width: searchField.frame.width, height: 1.0))
        border.backgroundColor = UIColor.rosterBackgroundColor()
        border.autoresizingMask = .flexibleWidth
        searchField.addSubview(border)
        
        view.addSubview(searchField)
        
        tableView.contentInset = UIEdgeInsets(top: searchField.frame.size.height, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0.0, y: -searchField.frame.size.height)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: searchField.frame.size.height, left: 0, bottom: 0, right: 0)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .plain)
        tableView.tableFooterView = UIView() // Prevent crash
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = 52.0
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 60.0, bottom: 0.0, right: 0.0)
        tableView.indicatorStyle = .black
        tableView.backgroundColor = UIColor.clear
        
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
        
        searchLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.width, height: 44.0))
        searchLabel.text = ""
        searchLabel.textColor = UIColor.rosterCellSubtitleColor()
        searchLabel.textAlignment = .center
        searchLabel.font = UIFont.systemFont(ofSize: 14.0)
        tableView.tableFooterView = searchLabel
        
        aboutLabel = UILabel(frame: view.frame)
        aboutLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if case .serverSide = searchBase {
            let placeholder = NSMutableAttributedString(string: "Search for People on\nRedRoster", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24.0)])
            placeholder.append(NSMutableAttributedString(string: "\n\nView their courses and schedules.", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)]))
            aboutLabel.attributedText = placeholder
        } else {
            aboutLabel.attributedText = NSMutableAttributedString(string: "No students", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24.0)])
        }
        
        aboutLabel.textColor = UIColor.lightGray
        aboutLabel.lineBreakMode = .byWordWrapping
        aboutLabel.numberOfLines = 4
        aboutLabel.textAlignment = .center
        
        view.addSubview(aboutLabel)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func viewTapped(_ gesture: UITapGestureRecognizer) {
        if !searchField.frame.contains(gesture.location(in: view)) {
            view.endEditing(true)
        }
    }
    
    func filterTableView(forQuery query: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchServerSide), object: nil)
        if query.components(separatedBy: " ").count > 2 {
            filteredUsers = []
            tableView.reloadData()
            searchLabel.text = "No results"
        } else if query.isEmpty {
            switch searchBase {
            case .users(let users):
                searchLabel.text = ""
                filteredUsers = users
                tableView.reloadData()
                aboutLabel.isHidden = !users.isEmpty
            case .serverSide:
                searchLabel.text = ""
                tableView.isHidden = true
                aboutLabel.isHidden = false
                
                filteredUsers = []
                tableView.reloadData()
            }
        } else {
            searchLabel.text = "Searching..."
            tableView.isHidden = false
            switch searchBase {
            case .serverSide:
                aboutLabel.isHidden = true
                perform(#selector(searchServerSide), with: nil, afterDelay: 0.5)
            case .users(let users):
                filteredUsers = users.filter {
                    ($0.fullName.range(of: query, options: [.caseInsensitive]) != nil
                    || $0.email.range(of: query, options: [.caseInsensitive]) != nil)
                    && $0.email != "redrostertester@gmail.com"
                }
                tableView.reloadData()
                searchLabel.text = filteredUsers.isEmpty ? "No results" : ""
            }
            
        }
    }
    
    func searchServerSide() {
        let query = searchField.text ?? ""
        NetworkManager.searchUsers(withQuery: query) { users in
            if let users = users {
                self.filteredUsers = users.filter { $0.email != "redrostertester@gmail.com" }
                self.tableView.reloadData()
                self.searchLabel.text = users.isEmpty ? "No results" : ""
            }
        }
    }
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = filteredUsers[indexPath.row]
        
        cell.configure(user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = filteredUsers[indexPath.row]
        let profileViewController = ProfileViewController()
        profileViewController.user = user
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}

extension PeopleViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PeopleViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filterTableView(forQuery: "")
        return true
    }
    
    func textFieldChanged() {
        filterTableView(forQuery: searchField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
