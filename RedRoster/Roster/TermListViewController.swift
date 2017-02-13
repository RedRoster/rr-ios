//
//  TermListViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/27/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import RealmSwift

class TermListViewController: RosterViewController, UITableViewDataSource, UITableViewDelegate {
    
    var terms: Results<Term> = try! Realm().objects(Term.self)
    var termsDict: [Int:[Term]] = [:]
    var years: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Course Roster"
        
        setupTableView()
        setupRetryButton()
        fetch()
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.register(UINib(nibName: "TermCell", bundle: nil), forCellReuseIdentifier: "TermCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56.0
    }
    
    override func fetch() {
        if terms.isEmpty {
            tableView.alpha = 0.0
            setupActivityIndicator()
        }
        
        setupNotification(self.terms)
        
        NetworkManager.fetchTerms { error in
            self.activityIndicator?.removeFromSuperview()
            
            if let error = error {
                self.alert(errorMessage: error.localizedDescription) { Void in
                    if self.terms.isEmpty {
                        self.retryButton.fadeShow()
                    }
                }
            }
        }
    }
    
    override func configureTableView() {
        if !terms.isEmpty {
            termsDict.removeAll()
            
            for term in terms {
                if termsDict[term.year] == nil {
                    termsDict[term.year] = [term]
                } else {
                    termsDict[term.year]?.insert(term, at: 0)
                }
            }
            
            for (year, terms) in termsDict {
                termsDict[year] = terms.sorted { $0.season.sortIndex < $1.season.sortIndex }
            }
            
            years = Array(termsDict.keys).sorted { $1 < $0 }
            
            tableView.reloadData()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.alpha = 1.0
            }) 
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsDict[years[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermCell", for: indexPath) as! TermCell
        let year = years[indexPath.section]
        let term = termsDict[year]![indexPath.row]
        
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        cell.selectedBackgroundView = background
        
        cell.iconImageView.image = UIImage(named: term.season.description.lowercased())
        cell.iconImageView.tintColor = UIColor.rosterCellTitleColor()
        
        cell.seasonLabel.textColor = UIColor.rosterCellTitleColor()
        cell.seasonLabel.text = term.season.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let term = termsDict[years[indexPath.section]]![indexPath.row]
        let subjectsViewController = SubjectsViewController()
        subjectsViewController.term = term
        navigationController?.pushViewController(subjectsViewController, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(years[section])"
    }
}
