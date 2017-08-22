//
//  ProfileViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 6/2/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    let HeaderSpacing: CGFloat = 32.0
    
    // MARK: - Properties
    
    var user: User!
    var schedules: [Schedule] = []
    var schedulesDict: [String:[Schedule]] = [:]
    var terms: [Term] = []
    
    var profileContainer: UIView!
    var publicSchedulesLabel: UILabel!
    var publicSchedulesTextLabel: UILabel!
    var tableView: UITableView!
    var emptyLabel: UILabel!
    var activityIndicator: DGActivityIndicatorView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setTheme()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Profile"
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.title = user.fullName
        
        setupProfile()
        setupTableView()
        setupActivityIndicator()
        setupBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetch()
    }
    
    func fetch() {
        NetworkManager.fetchSchedules(forUserWithid: user.id, readOnly: true) { schedules, error in
            if let error = error { self.alert(errorMessage: error.localizedDescription, completion: nil) } else {
                guard let schedules = schedules else { return }
                self.schedules = schedules.filter { $0.active }
                self.configureTableView(true)
            }
        }
    }
    
    // MARK: - Setup
    
    func setupProfile() {
        profileContainer = UIView()
        profileContainer.backgroundColor = UIColor.clear
        let profileImageView = UIImageView()
        profileImageView.frame.size = CGSize(width: 120.0, height: 120.0)
        profileImageView.center = CGPoint(x: view.frame.width / 2, y: HeaderSpacing + profileImageView.frame.width / 2)
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        if let imageURLString = user.imageURL,
            let imageURL = URL(string: imageURLString) {
            profileImageView.hnk_setImageFromURL(imageURL)
        } else if let imageURL = URL(string: "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/s128/photo.jpg") {
            profileImageView.hnk_setImageFromURL(imageURL)
        } else {
            profileImageView.isHidden = true
        }
        profileContainer.addSubview(profileImageView)
        
        let nameLabel = UILabel(frame: CGRect(x: 0.0, y: profileImageView.frame.maxY + 8.0, width: view.frame.width, height: 36.0))
        nameLabel.font = UIFont.systemFont(ofSize: 24.0)
        nameLabel.text = user.fullName
        nameLabel.textColor = UIColor.darkGray
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        profileContainer.addSubview(nameLabel)
        
        let emailLabel = UILabel(frame: CGRect(x: 0.0, y: nameLabel.frame.maxY, width: view.frame.width, height: 24.0))
        emailLabel.font = UIFont.systemFont(ofSize: 17.0)
        emailLabel.text = user.netID ?? user.email
        emailLabel.textColor = UIColor.lightGray
        emailLabel.textAlignment = .center
        emailLabel.adjustsFontSizeToFitWidth = true
        profileContainer.addSubview(emailLabel)
        
        profileContainer.frame.size = CGSize(width: view.frame.width, height: emailLabel.frame.maxY + 8.0)
        view.addSubview(profileContainer)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.height ?? 0.0)), style: .grouped)
        let insets = UIEdgeInsets(top: profileContainer.frame.height, left: 0.0, bottom: (tabBarController?.tabBar.frame.height ?? 0.0) + 88.0, right: 0.0)
        tableView.contentInset = insets
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        tableView.rowHeight = 88.0
        tableView.backgroundColor = UIColor.clear
        tableView.alpha = 0.0
        
        let headerContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.height, height: 66.0))
        publicSchedulesLabel = UILabel(frame: CGRect(x: 0.0, y: 8.0, width: tableView.frame.width, height: 21.0))
        publicSchedulesLabel.font = UIFont.systemFont(ofSize: 21.0)
        publicSchedulesLabel.textColor = UIColor.rosterRed()
        publicSchedulesLabel.textAlignment = .center
        publicSchedulesTextLabel = UILabel(frame: CGRect(x: 0.0, y: publicSchedulesLabel.frame.maxY + 4.0, width: tableView.frame.width, height: 17.0))
        publicSchedulesTextLabel.textColor = UIColor.darkGray
        publicSchedulesTextLabel.font = UIFont.systemFont(ofSize: 14.0)
        publicSchedulesTextLabel.textAlignment = .center
        headerContainer.addSubview(publicSchedulesLabel)
        headerContainer.addSubview(publicSchedulesTextLabel)
        headerContainer.frame.size = CGSize(width: tableView.frame.width, height: publicSchedulesTextLabel.frame.maxY + 8.0)
        tableView.tableHeaderView = headerContainer
        
        view.addSubview(tableView)
        
        emptyLabel = UILabel(frame: view.frame)
        emptyLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let placeholder = NSMutableAttributedString(string: "\(user.firstName) doesn't have any schedules yet", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)])
        
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
    
    func configureTableView(_ animated: Bool) {
        schedulesDict.removeAll()
        
        if schedules.isEmpty {
            emptyLabel.isHidden = false
            publicSchedulesLabel.text = ""
            publicSchedulesTextLabel.text = ""
        } else {
            emptyLabel.isHidden = true
            publicSchedulesLabel.text = "\(schedules.count)"
            publicSchedulesTextLabel.text = "Public Schedule\(schedules.count == 1 ? "" : "s")"
        }
        
        for schedule in schedules {
            let termSlug = schedule.termSlug
            if schedulesDict[termSlug] == nil {
                schedulesDict[termSlug] = [schedule]
            } else {
                if schedule.active {
                    schedulesDict[termSlug]?.insert(schedule, at: 0)
                } else {
                    schedulesDict[termSlug]?.append(schedule)
                }
            }
        }
        
        terms = schedulesDict.keys.map { Term.create($0) }
        terms.sort {
            if $0.year > $1.year { return true }
            else if $0.year == $1.year && $0.season.sortIndex < $1.season.sortIndex { return true }
            else { return false }
        }
        activityIndicator.removeFromSuperview()
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.alpha = 1.0
        }) 
        tableView.reloadData()
    }
    
    func setupBarButtons() {
        if presentingViewController != nil {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
            navigationItem.leftBarButtonItem = doneButton
        }
    }
    
    func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func settingsButtonPressed() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController")
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
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
        let scheduleViewController = ScheduleViewController(schedule: schedulesDict[terms[indexPath.section].slug]![indexPath.row], fromProfile: true)
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(terms[section].description)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.rosterHeaderTitleColor()
        header.backgroundView?.backgroundColor = UIColor.clear
    }
}
