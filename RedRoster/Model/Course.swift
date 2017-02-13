//
//  Course.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

enum GradeType: String {
    case Graded =           "GRD"
    case GradedNoAudit =    "GRI"
    case GradedEx =         "GRX"
    case SatUnsat =         "SUS"
    case SatUnsatEx =       "SUX"
    case SatUnsatNoAudit =  "SUI"
    case Opt =              "OPT"
    case OptNoAudit =       "OPI"
    case OptEx =            "OPX"
    case MultiTerm =        "BMT"
    case Unknown =          "???"
    
    var description: String {
        switch self {
        case .Graded:
            return "Graded"
        case .GradedNoAudit:
            return "Graded No Audit"
        case .GradedEx:
            return "Graded Exclusive"
        case .SatUnsat:
            return "Satisfactory/Unsatisfactory"
        case .SatUnsatEx:
            return "Satisfactory/Unsatisfactory Exclusive"
        case .SatUnsatNoAudit:
            return "Satisfactory/Unsatisfactory No Audit"
        case .Opt:
            return "Graded or Satisfactory/Unsatisfactory (Option)"
        case .OptNoAudit:
            return "Graded or Satisfactory/Unsatisfactory (Option) No Audit"
        case .OptEx:
            return "Graded or Satisfactory/Unsatisfactory (Option) Exclusive"
        case .MultiTerm:
            return "Multiterm (Ungraded)"
        case .Unknown:
            return "Unknown"
        }
    }
}

struct ReviewStatistics {
    var difficulty: Float
    var material: Float
    var lecture: Float
    var officeHours: Float
        
    static func create(_ json: JSON) -> ReviewStatistics {
        var statistics = ReviewStatistics(difficulty: 0.0, material: 0.0, lecture: 0.0, officeHours: 0.0)
        statistics.difficulty = json["difficulty_score"].floatValue
        statistics.material = json["material_score"].floatValue
        statistics.lecture = json["lecture_score"].floatValue
        statistics.officeHours = json["office_hours_score"].floatValue
        return statistics
    }
}

/** A Course represents a course of study. It has different classes from which students may choose. */
class Course: Object {
    
    /// The serialized primary key, consisting of [id]-[offerNumber], e.g. 358498-2
    dynamic var id: String = ""
    
    /// The course id for the master course
    dynamic var courseId: Int = 0
    
    /// Active term (for course view)
    dynamic var activeTermSlug: String = ""
    
    /// Active course number (for search or schedule)
    dynamic var activeCourseNumber: Int = 0
    
    /// Active subject abbreviation (for search or schedule)
    dynamic var activeSubjectAbbreviation: String = ""
    
    /// The list of possible crosslistings for this course
    let crosslistings = List<Crosslisting>()
    
    /// The course offer number
    dynamic var offerNumber: Int = 0
    
    /// The title for the Course, e.g. "Engineering General Chemistry"
    dynamic var title: String = ""
    
    /// A shorter title for the Course, e.g. "Engineering General Chem"
    dynamic var titleShort: String = ""
    
    /// The description of the Course, e.g. "Covers basic chemical concepts, such as..."
    dynamic var courseDescription: String = ""
    
    /// The grading method of the Course, e.g. Graded
    dynamic var gradeTypeString: String = ""
    
    var gradeType: GradeType {
        return GradeType(rawValue: gradeTypeString) ?? .Unknown
    }
    
    /// The maximum number of credits if graded with a range. If there is no range, this is the number of credits available.
    dynamic var maxCredit: Int = 0
    
    /// Some classes have a range of acceptable credits. minCredit is the lower value of the range, if it exists, or equal to the max credit otherwise
    dynamic var minCredit: Int = 0
    
    /// The beginning day of classes
    dynamic var startDate: Date = Date.unixTime
    
    /// The beginning day of classes
    dynamic var endDate: Date = Date.unixTime
    
    /// The subject to which this Course belongs
    let subjects = LinkingObjects(fromType: Subject.self, property: "courses")
    
    /// Sections that are required in order to enroll
    dynamic var requiredSectionTypesString: String = ""
    var requiredSectionTypes: [SectionType] {
        get {
            return requiredSectionTypesString.isEmpty ? [] : requiredSectionTypesString.components(separatedBy: RealmStringSeparator).flatMap { SectionType(rawValue: $0) }
        }
        set {
            requiredSectionTypesString = newValue.map { $0.rawValue }.joined(separator: RealmStringSeparator)
        }
    }
    
    /// All sections that this course has
    let availableSections = List<Section>()
    
    /// Prerequisites
    dynamic var prerequisitesString: String = ""
    
    // MARK: - Ignored Properties
    
    override static func ignoredProperties() -> [String] {
        return ["gradeType", "requiredSectionTypes", "crossListings", "shortHand", "users"]
    }
    
    /// The shorthand name for this course, e.g. CHEM 2090
    var shortHand: String {
        return "\(activeSubjectAbbreviation) \(activeCourseNumber)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(_ json: JSON, readOnly: Bool) -> (Course, [User]?) {
        var json: JSON = json
        if json["course"].exists() {
            json = json["course"]
        }
        guard let courseId = json["crse_id"].int,
            let offerNumber = json["course_offer_number"].int else { fatalError() }
        let id = "\(courseId)-\(offerNumber)"
        let course: Course = readOnly ? Course(value: ["id" : id]) : try! Realm().object(ofType: Course.self, forPrimaryKey: id) ?? Course(value: ["id" : id])
        course.courseId = courseId
        course.offerNumber = offerNumber
        
        if let term = json["term"].string { course.activeTermSlug = term }
        if let subject = json["subject"].string { course.activeSubjectAbbreviation = subject }
        if let courseNumber = Int(json["catalog_number"].stringValue) { course.activeCourseNumber = courseNumber }
        
        if let title = json["title_long"].string { course.title = title }
        else if let title = json["title"].string { course.title = title }
        if let titleShort = json["title_short"].string { course.titleShort = titleShort }
        if let description = json["description"].string { course.courseDescription = description }
        
        if let startDateString = json["begin_date"].string,
            let startDate = NetworkManager.dateFormatter.date(from: startDateString) { course.startDate = startDate }
        if let endDateString = json["end_date"].string,
            let endDate = NetworkManager.dateFormatter.date(from: endDateString) { course.endDate = endDate }
        
        if let gradeTypeString = json["grading_basis"].string { course.gradeTypeString = gradeTypeString }
        if let minCredit = json["credits_minimum"].int { course.minCredit = minCredit }
        if let maxCredit = json["credits_maximum"].int { course.maxCredit = maxCredit }
        
        if let requiredSectionTypes = json["required_sections"].array?.flatMap({ SectionType(rawValue: $0.stringValue) }) { course.requiredSectionTypes = requiredSectionTypes }
        
        if let availableSections = json["sections"].array?.map({ Section.create($0, readOnly: readOnly, offerNumber: course.offerNumber) }) {
            course.availableSections.removeAll()
            course.availableSections.append(objectsIn: availableSections)
        }
        if let crosslistings = json["cross_listings"].array?.map({ Crosslisting.create($0) }) {
            course.crosslistings.removeAll()
            course.crosslistings.append(objectsIn: crosslistings)
        }
        if let prerequisitesString = json["prerequisites"].string { course.prerequisitesString = prerequisitesString }
        
        let users = json["people_in_course"].array?.map { User(json: $0) }
        
        return (course, users)
    }
    
}

struct CourseResult {
    var id: Int
    var number: Int
    var offerNumber: Int
    var title: String
    var subject: String
    var termSlug: String
    var shortHand: String {
        return "\(subject) \(number)"
    }
}
