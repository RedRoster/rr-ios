//
//  AddReviewViewController.swift
//  RedRoster
//
//  Created by Joseph Antonakakis on 5/13/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController, RatingsDelegate {
    
    var course: Course!
    let terms: [Term] = {
        let calendar = Calendar.current
        let year = (calendar as NSCalendar).component(.year, from: Date())
        
        var terms: [Term] = []
        for year in 2013...year {
            for season in [Season.Winter, Season.Spring, Season.Summer, Season.Fall] {
                let slug = "\(season.rawValue)\(year - 2000)"
                terms.insert(Term.create(slug), at: 0)
            }
        }
        
        return terms
    }()
    
    var termChoiceIndex: Int? = nil
    
    var tableView: UITableView!
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Review \(course.shortHand)"
        navigationController?.setTheme()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        setupBarButtons()
        setupTableView()
        setupTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func setupBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.autoresizingMask = .flexibleHeight
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PickTermCell", bundle: nil), forCellReuseIdentifier: "PickTermCell")
        tableView.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "SliderCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "SubmitCell", bundle: nil), forCellReuseIdentifier: "SubmitCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.keyboardDismissMode = .onDrag
        
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        
        view.addSubview(tableView)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func cancelButtonPressed () {
        dismiss(animated: true, completion: nil)
    }
    
    var lectureRating: Float = 3
    var officeRating: Float = 3
    var workRating: Float = 3
    var materialRating: Float = 3
    
    var comments: String = ""
    
    func ratingDidChange(_ index: Int, value: Float) {
        switch index {
        case 2:
            lectureRating = value
            break
        case 3:
            officeRating = value
            break
        case 4:
            workRating = value
            break
        case 5:
            materialRating = value
            break
        default:
            return
        }
    }
    
    func doneButtonPressed() {
        
        let statistics = ReviewStatistics(difficulty: workRating, material: materialRating, lecture: lectureRating, officeHours: officeRating)
        
        let trimmedComments = comments.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let termChoiceIndex = termChoiceIndex {
            NetworkManager.postReview(course, ratings: statistics, feedback: trimmedComments, term: terms[termChoiceIndex]) { statistics, reviews, error in
                if let error = error {
                    self.alert(errorMessage: error.localizedDescription, completion: nil)
                } else {
                    if let reviewsViewController = ((self.presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.topViewController as? ReviewsViewController
                    ?? (self.presentingViewController as? UINavigationController)?.topViewController as? ReviewsViewController {
                        reviewsViewController.averageStatistics = statistics
                        reviewsViewController.reviews = reviews ?? []
                        reviewsViewController.configureView()
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error Posting Review", message: "You need to choose which term you took the course in.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension AddReviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickTermCell", for: indexPath) as! PickTermCell
            cell.textLabel?.text = "Term"
            cell.textLabel?.textColor = UIColor.darkGray
            cell.detailTextLabel?.text = termChoiceIndex == nil ? "Choose Term" : terms[termChoiceIndex!].description
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            
            let background = UIView()
            background.backgroundColor = UIColor.rosterCellSelectionColor()
            cell.selectedBackgroundView = background
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            return cell
        case 2...5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            cell.index = indexPath.section
            cell.delegate = self
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitCell", for: indexPath) as! SubmitCell
            cell.titleLabel.text = "Submit Review"
            cell.titleLabel.textColor = UIColor.rosterRed()
            cell.backgroundColor = UIColor.rosterCellBackgroundColor()
            
            let background = UIView()
            background.backgroundColor = UIColor.rosterCellSelectionColor()
            cell.selectedBackgroundView = background
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Term"
        case 2:
            return "Lecture"
        case 3:
            return "Office Hours"
        case 4:
            return "Work"
        case 5:
            return "Material"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "The term during which you took the course."
        case 1:
            return textFooter()
        case 2:
            return "How useful were the lectures?\n1: Not at all useful; 5: Very useful"
        case 3:
            return "How helpful were the office hours?\n1: Not at all helpful; 5: Very helpful"
        case 4:
            return "How large was the workload?\n1: Not at all large; 5: Very large"
        case 5:
            return "How captivating was the material?\n1: Not at all captivating; 5: Very captivating"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let termPickerViewController = TermPickerViewController()
            termPickerViewController.terms = terms
            termPickerViewController.termChoiceIndex = termChoiceIndex
            present(termPickerViewController, animated: true, completion: nil)
        }
        
        if indexPath.section == tableView.numberOfSections - 1 {
            doneButtonPressed()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return UITableViewAutomaticDimension
        }
        return 44.0
    }
    
    func textFooter() -> String {
        let characters = comments.characters.count
        return "Your comments will be displayed publicly along with your name and profile picture. \(characters == 0 ? "200 characters max" : "\(200 - characters >= 0 ? "\(200 - characters) characters remaining" : "\(characters - 200) characters over the limit")")."
    }
    
}

extension AddReviewViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        comments = textView.text
        if textView.frame.maxY > tableView.frame.height / 2 {
            tableView.setContentOffset(CGPoint(x: 0.0, y: tableView.contentOffset.y + 17.0), animated: true)
        }
        
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        
        if let containerView = tableView.footerView(forSection: 1) {
            containerView.textLabel?.text = textFooter()
            containerView.sizeToFit()
        }
        
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
