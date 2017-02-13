//
//  NewScheduleViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 5/1/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift
import DGActivityIndicatorView
import PickerView

class NewScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    func cancelButtonPressed() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func createButtonPressed() {
        guard let terms = terms else { return }
        createButton.isEnabled = false
        let textFieldCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell
        let name = textFieldCell?.textField.text ?? "My Schedule"
        NetworkManager.postSchedule(name, termWithSlug: terms[termChoiceIndex].slug, active: active) { error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription, completion: nil)
                self.createButton.isEnabled = true
            } else {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func textFieldChanged(_ sender: UITextField) {
        createButton.isEnabled = !(sender.text?.isEmpty ?? true)
    }
    
    func publicSwitchChanged(_ sender: UISwitch) {
        active = sender.isOn
    }
    
    var active: Bool = true
    
    var tableView: UITableView!
    var activityIndicator: DGActivityIndicatorView!
    
    var cancelButton: UIBarButtonItem!
    var createButton: UIBarButtonItem!
    
    var terms: [Term]?
    var termChoiceIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Schedule"
        navigationController?.setTheme()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        setupButtons()
        setupTableView()
        setupActivityIndicator()
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.startAnimating()
    }
    
    func setupButtons() {
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
        
        createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createButtonPressed))
        navigationItem.rightBarButtonItem = createButton
        createButton.isEnabled = false
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.maxY ?? 0)), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.alpha = 0
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "PickTermCell", bundle: nil), forCellReuseIdentifier: "PickTermCell")
        tableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
        
        view.addSubview(tableView)
    }
    
    func setupActivityIndicator() {
        activityIndicator = DGActivityIndicatorView(type: .threeDots, tintColor: UIColor.darkGray)
        activityIndicator.center = CGPoint(x: tableView.bounds.width / 2, y: tableView.bounds.height / 2)
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(activityIndicator)
    }
    
    func fetch() {
        NetworkManager.fetchTerms { error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription) {
                    self.activityIndicator.removeFromSuperview()
                }
            } else {
                let realm = try! Realm()
                realm.refresh()
                self.terms = Array(realm.objects(Term.self)).sorted {
                    if $0.year > $1.year { return true }
                    else if $0.year == $1.year && $0.season.sortIndex < $1.season.sortIndex { return true }
                    else { return false }
                }
                self.configureTableView()
            }
        }
    }
    
    func configureTableView() {
        activityIndicator.removeFromSuperview()
        tableView.reloadData()
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.alpha = 1.0
        }) 
        if let textFieldCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell {
            textFieldCell.textField.becomeFirstResponder()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            
            cell.textField.placeholder = "Name"
            cell.textField.textColor = UIColor.darkGray
            cell.textField.font = UIFont.systemFont(ofSize: 17.0)
            cell.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            
            cell.selectionStyle = .none
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickTermCell", for: indexPath) as! PickTermCell
            
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            
            cell.textLabel?.text = "Term"
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.detailTextLabel?.text = terms?[termChoiceIndex].description
            cell.detailTextLabel?.textColor = UIColor.rosterRed()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        
        cell.titleLabel.text = "Make Public"
        cell.titleLabel.textColor = UIColor.darkGray
        cell.titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        
        cell.switchControl.thumbTintColor = UIColor.white
        cell.switchControl.tintColor = UIColor.rosterBackgroundColor()
        cell.switchControl.onTintColor = UIColor.rosterRed()
        cell.switchControl.isOn = active
        cell.switchControl.addTarget(self, action: #selector(publicSwitchChanged(_:)), for: .valueChanged)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 55.0
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if let terms = terms {
                let termPickerViewController = TermPickerViewController()
                termPickerViewController.terms = Array(terms)
                termPickerViewController.termChoiceIndex = termChoiceIndex
                present(termPickerViewController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "The term this schedule is in."
        }
        if section == 2 {
            return "Make this schedule your public schedule for the selected term, visible to other students. This should be the schedule you're enrolled in or pre-enrolled in."
        }
        
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}
