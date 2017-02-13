//
//  Schedule.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/** An RRSchedule is a collection of classes a user has chosen. */
class Schedule: Object {
    
    /// The unique identifier for this Schedule
    dynamic var id: Int = 0
    
    /// The name of this Schedule
    dynamic var name: String = ""
    
    /// The Schedule's Term
    dynamic var term: Term?
    
    /// The Schedule's Term when read-only
    dynamic var termSlug: String = ""
    
    /// Whether the Schedule has a conflict or not
    dynamic var conflicted: Bool = false
    
    /// Whether the Schedule is active or not
    dynamic var active: Bool = false
    
    /// Minimum number of credits this schedule gives
    dynamic var minCredits: Int = 0
    
    /// Maximum number of credits this schedule gives
    dynamic var maxCredits: Int = 0
    
    /// When this schedule was created
    dynamic var creationDate: Date = .unixTime
    
    /// Courses in this Schedule
    let courses = List<Course>()
    
    /// Elements in this Schedule
    let elements = List<Element>()
    
    /// Number of hours a week this Schedule represents
    var hours: TimeInterval {
        let seconds = elements
            .flatMap { $0.section }
            .reduce(0.0) { $0 + ($1.endTime.timeIntervalSince($1.startTime) * Double($1.days.count))  }
        return seconds / 3600
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(_ json: JSON, readOnly: Bool) -> Schedule {
        let json = json["schedule"]
        guard let id = json["id"].int else { fatalError() }
        let schedule: Schedule = readOnly ? Schedule(value: ["id" : id]) : try! Realm().object(ofType: Schedule.self, forPrimaryKey: id) ?? Schedule(value: ["id" : id])
        
        if let name = json["name"].string { schedule.name = name }
        if let term = json["term"].string {
            schedule.term = Term.create(term)
            schedule.termSlug = term
        }
        
        if let active = json["is_active"].bool { schedule.active = active }
        
        if let coursesArray = json["courses"].array {
            schedule.courses.removeAll()
            schedule.elements.removeAll()
            for courseJSON in coursesArray {
                if let elements = courseJSON["schedule_elements"].array?.map({ Element.create($0, courseId: courseJSON["course"]["crse_id"].intValue, readOnly: readOnly, offerNumber: courseJSON["course"]["course_offer_number"].int!) }) {
                    schedule.elements.append(objectsIn: elements)
                }
                schedule.courses.append(Course.create(courseJSON["course"], readOnly: readOnly).0)
            }
        }
        
        if let conflicted = json["schedule_conflict"].bool { schedule.conflicted = conflicted }
        
        if let minCredits = json["min_sched_credits"].int { schedule.minCredits = minCredits }
        if let maxCredits = json["max_sched_credits"].int { schedule.maxCredits = maxCredits }
        
        if let creationDateString = json["created_at"].string,
            let creationDate = RailsDateFormatter.date(from: creationDateString) {
            schedule.creationDate = creationDate
        }
        
        return schedule
    }
}
