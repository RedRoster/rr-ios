//
//  RatingBar.swift
//  RedRoster
//
//  Created by Daniel Li on 4/2/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class RatingBar: UIProgressView {

    override func setProgress(_ progress: Float, animated: Bool) {
        self.progress = progress
        if animated {
            UIView.animate(withDuration: RatingsAnimationDuration, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.layoutIfNeeded()
                }, completion: nil)
        } else {
            self.layoutIfNeeded()
        }
    }

}
