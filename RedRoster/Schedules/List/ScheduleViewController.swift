//
//  ScheduleViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleViewController: UIViewController {
    
    var schedule: Schedule
    var fromProfile: Bool
    
    var segmentedContainer: UIView!
    var segmentedControl: UISegmentedControl!
    var scrollView: UIScrollView!
    
    init(schedule: Schedule, fromProfile: Bool = false) {
        self.schedule = schedule
        self.fromProfile = fromProfile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = schedule.name
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        setupSegmentedControl()
        setupScrollView()
        
        if !fromProfile {
            setupBarButtons()
        }
    }
    
    func setupSegmentedControl() {
        segmentedContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 36.0))
        segmentedContainer.backgroundColor = UIColor.rosterRed()
        
        segmentedControl = UISegmentedControl(items: ["List", "Calendar"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.frame = CGRect(x: 8.0, y: 0.0, width: view.frame.width - 16.0, height: 28.0)
        segmentedControl.backgroundColor = UIColor.rosterRed()
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped), for: .valueChanged)
        
        segmentedContainer.addSubview(segmentedControl)
        view.addSubview(segmentedContainer)
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: segmentedContainer.frame.maxY, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0) - segmentedContainer.frame.maxY))
        
        let scheduleTableViewController = ScheduleTableViewController(schedule: schedule, fromProfile: fromProfile, frame: CGRect(x: 0.0, y: 0.0, width: scrollView.frame.width, height: scrollView.frame.size.height))
        scrollView.addSubview(scheduleTableViewController.view)
        addChildViewController(scheduleTableViewController)
        
        let flowCalendarViewController = FlowCalendarViewController(schedule: schedule, fromProfile: fromProfile, frame: CGRect(x: scrollView.frame.width, y: 0.0, width: scrollView.frame.width, height: scrollView.frame.size.height))
        scrollView.addSubview(flowCalendarViewController.view)
        addChildViewController(flowCalendarViewController)
        
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: 1.0)
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        
        view.addSubview(scrollView)
    }
    
    func setupBarButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        let editButton = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    func addButtonPressed() {
        let subjectsViewController = SubjectsViewController()
        subjectsViewController.term = schedule.term
        subjectsViewController.schedule = schedule
        
        let navigationController = UINavigationController(rootViewController: subjectsViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func editButtonPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if !schedule.active {
            alertController.addAction(UIAlertAction(title: "Make Public", style: .default) { Void in
                NetworkManager.makeSchedulePublic(withId: self.schedule.id) { error in
                    if let error = error {
                        self.alert(errorMessage: error.localizedDescription, completion: nil)
                        return
                    }
                }
                })
        }
        
        alertController.addAction(UIAlertAction(title: "Rename Schedule", style: .default) { Void in
            let renameController = UIAlertController(title: "Rename Schedule", message: nil, preferredStyle: .alert)
            renameController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            let doneAction = UIAlertAction(title: "Done", style: .default) { Void in
                guard let name = renameController.textFields?.first?.text else { return }
                NetworkManager.renameSchedule(withId: self.schedule.id, toName: name) { error in
                    if let error = error { self.alert(errorMessage: error.localizedDescription, completion: nil) }
                    else {
                        self.title = name
                    }
                }
            }
            
            renameController.addAction(doneAction)
            renameController.addTextField { textField in
                textField.placeholder = "Name"
                textField.autocapitalizationType = .words
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                    doneAction.isEnabled = textField.text != ""
                }
            }
            self.present(renameController, animated: true, completion: nil)
            })
        alertController.addAction(UIAlertAction(title: "Delete Schedule", style: .destructive) { Void in
            let deleteController = UIAlertController(title: "Really delete \(self.schedule.name)?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
            deleteController.addAction(UIAlertAction(title: "Delete Forever", style: .destructive) { Void in
                NetworkManager.deleteSchedule(withId: self.schedule.id) { error in
                    if let error = error {
                        self.alert(errorMessage: error.localizedDescription, completion: nil)
                    } else {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                })
            deleteController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(deleteController, animated: true, completion: nil)
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func segmentedControlTapped() {
        if segmentedControl.selectedSegmentIndex == 0 {
            scrollView.contentOffset.x = 0.0
        } else {
            scrollView.contentOffset.x = view.frame.width
        }
    }
    
}
