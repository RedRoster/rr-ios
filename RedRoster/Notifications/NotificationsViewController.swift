//
//  NotificationsViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 5/30/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

var Notifications: [Notification] = []

class NotificationsViewController: UIViewController {

    var tableView: UITableView!
    var emptyLabel: UILabel!
    
    var clearButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifications"
        view.backgroundColor = UIColor.rosterBackgroundColor()
        navigationController?.setTheme()
        
        setupClearButton()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
        updateEmpty()
    }
    
    func setupClearButton() {
        clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonPressed))
        navigationItem.rightBarButtonItem = clearButton
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.rowHeight = 52.0
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        emptyLabel = UILabel(frame: view.frame)
        emptyLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let placeholder = NSMutableAttributedString(string: "No Notifications", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 24.0)])
        
        emptyLabel.attributedText = placeholder
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.numberOfLines = 3
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        
        view.addSubview(emptyLabel)
    }
    
    func clearButtonPressed() {
        
    }
    
    func updateEmpty() {
        if Notifications.isEmpty {
            emptyLabel.fadeShow()
            clearButton.isEnabled = false
            tableView.isScrollEnabled = false
        } else {
            emptyLabel.fadeHide()
            clearButton.isEnabled = true
            tableView.isScrollEnabled = true
        }
        
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
