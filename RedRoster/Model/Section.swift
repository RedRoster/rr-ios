//
//  Class.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

enum SectionType: String {
    case Lecture =      "LEC"
    case Discussion =   "DIS"
    case Seminar =      "SEM"
    case Research =     "RSC"
    case Independent =  "IND"
    case TeachAssist =  "TA"
    case Laboratory =   "LAB"
    case Studio =       "STU"
    case Unknown =      "???"
    
    var description: String {
        switch self {
        case .Lecture:
            return "Lecture"
        case .Discussion:
            return "Discussion"
        case .Seminar:
            return "Seminar"
        case .Research:
            return "Research"
        case .Independent:
            return "Independent Study"
        case .TeachAssist:
            return "Teaching Assistant"
        case .Laboratory:
            return "Laboratory"
        case .Studio:
            return "Studio"
        case .Unknown:
            return "???"
        }
    }
}

//struct Instructor {
//    var name: String
//    var netID: String
//    
//    init(json: JSON) {
//        name = json[APIKey.InFirstName].string! + " " + json[APIKey.InMiddleName].string! + " " + json[APIKey.InLastName].string!
//        netID = json[APIKey.InNetId].string!
//    }
//}
//
//struct Meeting {
//    var startDate: NSDate?
//    var endDate: NSDate?
//    var startTime: NSDate?
//    var endTime: NSDate?
//    var daysString: String
//    var days: [WeekDay]
//    var location: String?
//    
//    init(json: JSON) {
//        startDate = NetworkManager.dateFormatter.dateFromString(json[APIKey.MeetingStartDate].string ?? "")
//        endDate = NetworkManager.dateFormatter.dateFromString(json[APIKey.MeetingEndDate].string ?? "")
//        startTime = NetworkManager.timeFormatter.dateFromString(json[APIKey.MeetingStartTime].string ?? json[APIKey.ElementStartTime].string!)
//        endTime = NetworkManager.timeFormatter.dateFromString(json[APIKey.MeetingEndTime].string ?? json[APIKey.ElementEndTime].string!)
//        daysString = json[APIKey.Days].string ?? json[APIKey.ElementDays].string!
//        location = json[APIKey.Location].string ?? json[APIKey.ElementLocation].string
//        
//        var string = daysString
//        days = []
//        if string.hasSuffix("Su") {
//            days.append(.Sunday)
//            daysString = string.substringToIndex(string.endIndex.advancedBy(-2))
//        } else if string.hasPrefix("Su") {
//            days.append(.Sunday)
//            string = string.substringFromIndex(string.startIndex.advancedBy(2))
//        }
//        days.appendContentsOf(string.characters.map { WeekDay(rawValue: String($0))! })
//    }
//}

/** A Section represents an enrollable section of a Course. It could be a Lecture, Discussion, or Seminar. */
class Section: Object {
    
    /// The section identifier, e.g. 214
    dynamic var sectionNumber: String = ""
    
    /// The type of class, e.g. Lecture
    dynamic var sectionTypeString: String = ""
    var sectionType: SectionType {
        return SectionType(rawValue: sectionTypeString) ?? .Unknown
    }
    
    /// The unique id of the section which is [classNumber]-[courseOfferNumber]
    dynamic var id: String = ""
    
    /// The unique class number of this Section, e.g. 10984
    dynamic var classNumber: Int = 0
    
    /// When the Section begins
    dynamic var startTime: Date = .unixTime
    
    /// When the Section ends
    dynamic var endTime: Date = .unixTime
    
    /// The days of the week that the Section meets
    dynamic var daysString: String = ""
    var days: [WeekDay] {
        get {
            var string = daysString
            var days: [WeekDay] = []
            if string.hasSuffix("Su") {
                days.append(.Sunday)
                string = string.substring(to: string.characters.index(string.endIndex, offsetBy: -2))
            } else if string.hasPrefix("Su") {
                days.append(.Sunday)
                string = string.substring(from: string.characters.index(string.startIndex, offsetBy: 2))
            }
            days.append(contentsOf: string.characters.map { WeekDay(rawValue: String($0))! })
            return days
        }
        set {
            daysString = newValue.map { $0.rawValue }.joined(separator: RealmStringSeparator)
        }
    }
    
    dynamic var location: String = ""
    
    /// The Enroll Group that this section belongs to
    dynamic var enrollGroup: Int = 0
    
    /// Possible description of topic, e.g. FWS titles
    dynamic var topicDescription: String = ""
    
    /// The instructors teaching the Course
//    var instructors: [Instructor]
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(_ json: JSON, readOnly: Bool, offerNumber: Int) -> Section {
        guard let classNumber = json["section_num"].int else { fatalError() }
        let id = "\(classNumber)-\(offerNumber)"
        let section: Section = readOnly ? Section(value: ["id" : id]) : try! Realm().object(ofType: Section.self, forPrimaryKey: id) ?? Section(value: ["id" : id])
        section.classNumber = classNumber
        if let sectionNumber = json["class_number"].string { section.sectionNumber = sectionNumber }
        if let sectionTypeString = json["section_type"].string { section.sectionTypeString = sectionTypeString }
        if let startString = json["start_time"].string,
            let startTime = NetworkManager.timeFormatter.date(from: startString) {
            section.startTime = startTime
        }
        if let endString = json["end_time"].string,
            let endTime = NetworkManager.timeFormatter.date(from: endString) {
            section.endTime = endTime
        }
        if let dayString = json["day_pattern"].string { section.daysString = dayString }
        
        if let location = json["long_location"].string { section.location = location }
        
        if let enrollGroup = json["enroll_group"].int { section.enrollGroup = enrollGroup }
        if let description = json["topic_description"].string { section.topicDescription = description }
        
        return section
//        let instructors: [Instructor] = []
//        self.instructors = instructors
    }
}
