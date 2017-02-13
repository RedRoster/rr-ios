//
//  ReviewDetailViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 8/5/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class ReviewDetailViewController: UIViewController {

    var reviewLabel: UILabel!
    var review: Review!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rosterBackgroundColor()
        
        if review.feedback != "" {
            setupLabel()
        }
    }
    
    func setupLabel() {
        reviewLabel = UILabel(frame: CGRect(x: 8.0, y: 8.0, width: view.frame.width - 16.0, height: 0.0))
        reviewLabel.text = review.feedback
        reviewLabel.textColor = UIColor.rosterCellTitleColor()
        reviewLabel.font = UIFont.systemFont(ofSize: 14.0)
        reviewLabel.lineBreakMode = .byWordWrapping
        reviewLabel.numberOfLines = 0
        
        let height = reviewLabel.sizeThatFits(CGSize(width: view.frame.width - 16.0, height: CGFloat.greatestFiniteMagnitude)).height
        reviewLabel.frame.size.height = height
        
        let reviewBackground = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: reviewLabel.frame.maxY + 8.0))
        reviewBackground.backgroundColor = UIColor.rosterBackgroundColor()
        view.addSubview(reviewBackground)
        
        view.addSubview(reviewLabel)
    }
}
