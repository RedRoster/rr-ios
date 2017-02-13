//
//  Review.swift
//  RedRoster
//
//  Created by Daniel Li on 3/31/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Review {
    
    /// Term during which the author took this course
    var term: Term
    
    /// Course statistics that this Review made
    var statistics: ReviewStatistics
    
    /// Optional feedback for a course
    var feedback: String
    
    /// The User who posted this review
    var author: User
    
    /// The date when the review was posted
    var date: Date
    
    init(json: JSON) {
        let json = json["course_review"]
        let term = Term()
        term.slug = json["term"].stringValue
        self.term = term
        statistics = ReviewStatistics(difficulty: json["difficulty_score"].floatValue, material: json["difficulty_score"].floatValue, lecture: json["lecture_score"].floatValue, officeHours: json["office_hours_score"].floatValue)
        feedback = json["feedback"].stringValue
        author = User(json: json["user"])
        
        date = RailsDateFormatter.date(from: json["created_at"].stringValue) ?? .unixTime
    }
}
