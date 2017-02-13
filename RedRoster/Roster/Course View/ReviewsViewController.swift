//
//  ReviewsViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/30/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import UICountingLabel

class ReviewsViewController: UIViewController {
    
    var course: Course!
    var reviews: [Review] = []
    var averageStatistics: ReviewStatistics!
    
    var activityIndicator: DGActivityIndicatorView!
    
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var lectureBar: RatingBar!
    @IBOutlet weak var lectureLabel: UICountingLabel!
    @IBOutlet weak var officeBar: RatingBar!
    @IBOutlet weak var officeLabel: UICountingLabel!
    @IBOutlet weak var workBar: RatingBar!
    @IBOutlet weak var workLabel: UICountingLabel!
    @IBOutlet weak var materialBar: RatingBar!
    @IBOutlet weak var materialLabel: UICountingLabel!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        
        // TODO: maybe make backend check if user has done this before
        
        let addReviewViewController = AddReviewViewController()
        addReviewViewController.course = course
        let navigationController = UINavigationController(rootViewController: addReviewViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    var tableView: UITableView!
    var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reviews"
        
        view.backgroundColor = UIColor.rosterBackgroundColor()
        ratingsView.backgroundColor = UIColor.clear
        
        setupTableView()
        setupActivityIndicatorView()
        setupRatings()
        setupReviewButton()
        setupEmptyLabel()
        fetch()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        activityIndicator.center = center
        emptyLabel.center = center
    }
    
    func setupReviewButton() {
        view.bringSubview(toFront: reviewButton)
        reviewButton.backgroundColor = UIColor.rosterRed()
        reviewButton.layer.cornerRadius = 10.0
        reviewButton.setTitle("Write a Review", for: UIControlState())
        reviewButton.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    func setupActivityIndicatorView() {
        activityIndicator = DGActivityIndicatorView(type: .threeDots, tintColor: UIColor.darkGray)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: UIScreen.main.bounds.maxY - (navigationController?.navigationBar.frame.maxY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0.0)), style: .grouped)
        tableView.autoresizingMask = .flexibleWidth
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.indicatorStyle = .black
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 74.0
        tableView.contentInset = UIEdgeInsets(top: reviewButton.frame.maxY, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        tableView.alpha = 0.0
        view.addSubview(tableView)
    }
    
    func setupEmptyLabel() {
        emptyLabel = UILabel()
        emptyLabel.text = "No written reviews yet.\n Be the first to write one!"
        emptyLabel.font = UIFont.systemFont(ofSize: 17.0)
        emptyLabel.numberOfLines = 2
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.sizeToFit()
        emptyLabel.alpha = 0.0
        view.addSubview(emptyLabel)
    }
    
    func setupRatings() {
        lectureBar.progress = 0.0
        lectureBar.progressTintColor = UIColor.rosterRed()
        lectureLabel.text = "0"
        lectureLabel.textColor = UIColor.darkGray
        lectureLabel.format = "%.2f/5"
        officeBar.progress = 0.0
        officeBar.progressTintColor = UIColor.rosterRed()
        officeLabel.text = "0"
        officeLabel.textColor = UIColor.darkGray
        officeLabel.format = "%.2f/5"
        workBar.progress = 0.0
        workBar.progressTintColor = UIColor.rosterRed()
        workLabel.text = "0"
        workLabel.textColor = UIColor.darkGray
        workLabel.format = "%.2f/5"
        materialBar.progress = 0.0
        materialBar.progressTintColor = UIColor.rosterRed()
        materialLabel.text = "0"
        materialLabel.textColor = UIColor.darkGray
        materialLabel.format = "%.2f/5"
    }
    
    func fetch() {
        NetworkManager.fetchReviews(course) { statistics, reviews, error in
            if let error = error {
                self.alert(errorMessage: error.localizedDescription) { Void in
                    self.activityIndicator.removeFromSuperview()
                }
            } else {
                self.averageStatistics = statistics
                self.reviews = reviews ?? []
                self.configureView()
            }
        }
    }
    
    func configureView() {
        reviews = reviews
            .filter { !$0.feedback.isEmpty }
            .sorted { $0.date.compare($1.date as Date) == .orderedDescending }
        
        activityIndicator.removeFromSuperview()
        
        if reviews.isEmpty {
            emptyLabel.fadeShow()
            tableView.fadeHide()
        } else {
            emptyLabel.fadeHide()
            tableView.fadeShow()
        }
        
        lectureBar.setProgress(averageStatistics.lecture/5, animated: true)
        lectureLabel.countFromZero(to: CGFloat(averageStatistics.lecture), withDuration: RatingsAnimationDuration - 0.2)
        officeBar.setProgress(averageStatistics.officeHours/5, animated: true)
        officeLabel.countFromZero(to: CGFloat(averageStatistics.officeHours), withDuration: RatingsAnimationDuration - 0.2)
        workBar.setProgress(averageStatistics.difficulty/5, animated: true)
        workLabel.countFromZero(to: CGFloat(averageStatistics.difficulty), withDuration: RatingsAnimationDuration - 0.2)
        materialBar.setProgress(averageStatistics.material/5, animated: true)
        materialLabel.countFromZero(to: CGFloat(averageStatistics.material), withDuration: RatingsAnimationDuration - 0.2)
        
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ratingsView.alpha = -(1/180) * (scrollView.contentOffset.y + reviewButton.frame.maxY) + 1
        reviewButton.alpha = -(1/180) * (scrollView.contentOffset.y + reviewButton.frame.maxY) + 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkEndScrollPosition(shouldScrollUp: -scrollView.contentOffset.y < reviewButton.frame.maxY / 2)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            checkEndScrollPosition(shouldScrollUp: -scrollView.contentOffset.y < reviewButton.frame.maxY / 2)
        }
    }
    
    func checkEndScrollPosition(shouldScrollUp up: Bool) {
        if -tableView.contentOffset.y > 0.0 && -tableView.contentOffset.y < reviewButton.frame.maxY {
            tableView.setContentOffset(CGPoint(x: 0.0, y: up ? 0.0 : -reviewButton.frame.maxY), animated: true)
        }
    }
    
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        
        cell.nameLabel.text = review.author.fullName
        cell.nameLabel.textColor = UIColor.darkGray
        
        cell.termLabel.text = review.term.description
        cell.termLabel.textColor = UIColor.darkGray
        
        cell.contentLabel.text = review.feedback 
        cell.contentLabel.textColor = UIColor.darkGray
        
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        cell.selectedBackgroundView = background
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let review = reviews[indexPath.row]
        let reviewDetailViewController = ReviewDetailViewController()
        reviewDetailViewController.review = review
        navigationController?.pushViewController(reviewDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "REVIEWS"
    }
    
}
