//
//  RosterViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift
import DGActivityIndicatorView

class RosterViewController: UIViewController {
    
    // MARK: - Scheduling
    
    var schedule: Schedule? {
        didSet {
            if schedule != nil {
                addCancelButtonRight()
            }
        }
    }
    
    func addCancelButtonRight() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonPressed))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    func cancelButtonPressed() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Views
    
    var tableView: UITableView!
    var retryButton: UIButton!
    
    var activityIndicator: DGActivityIndicatorView?
    
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        navigationController?.setTheme()
    }
    
    func fetch() {
        
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .plain)
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.indicatorStyle = .black
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        view.addSubview(tableView)
    }
    
    func setupNotification<T : RealmCollection>(_ collection: T) {
        token = collection.addNotificationBlock { [weak self] changes in
            self?.configureTableView()
        }
    }
    
    func configureTableView() { }
    
    func setupRetryButton() {
        retryButton = UIButton()
        retryButton.frame.size = CGSize(width: 125.0, height: 25.0)
        retryButton.setTitle("Retry", for: UIControlState())
        retryButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        retryButton.setImage(UIImage(named: "retry"), for: UIControlState())
        retryButton.tintColor = UIColor.darkGray
        retryButton.imageView?.contentMode = .scaleAspectFit
        retryButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: -5.0)
        retryButton.center = CGPoint(x: view.center.x - 5.0, y: view.center.y)
        retryButton.addTarget(self, action: #selector(retryButtonPressed(_:)), for: .touchUpInside)
        
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    func retryButtonPressed(_ sender: UIButton) {
        setupActivityIndicator()
        activityIndicator?.startAnimating()
        retryButton.fadeHide()
        fetch()
    }
    
    func setupActivityIndicator() {
        let activityIndicator = DGActivityIndicatorView(type: .threeDots, tintColor: UIColor.darkGray)
        activityIndicator?.center = CGPoint(x: tableView.bounds.width / 2, y: tableView.bounds.height / 2)
        view.addSubview(activityIndicator!)
        activityIndicator?.startAnimating()
        self.activityIndicator = activityIndicator
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.rosterHeaderTitleColor()
        header.backgroundView?.backgroundColor = UIColor.rosterHeaderColor()
    }
    
}
