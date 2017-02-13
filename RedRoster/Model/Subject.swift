//
//  Subject.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/** A Subject represents a group of courses in a field of study. Its abbreviation (AEM, INFO, CS, etc.) is often used course. */
class Subject: Object {
    
    /// Name of the subject, e.g. "Engineering Introduction"
    dynamic var name: String = ""
    
    /// Abbreviation of the Subject, e.g. "ENGRI"
    dynamic var abbreviation: String = ""
    
    /// Unique serial of the Subject which is abbreviation + slug of the Term it is in
    dynamic var id: String = ""
    
    /// The list of Courses in this Subject
    let courses = List<Course>()
    
    /// The Term to which this Subject belongs
    fileprivate let terms = LinkingObjects(fromType: Term.self, property: "subjects")
    
    var term: Term? {
        return terms.first
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["term"]
    }
    
    static func create(_ json: JSON, termSlug: String) -> Subject {
        guard let abbreviation = json["value"].string else { fatalError() }
        let id = abbreviation + termSlug
        let subject: Subject = try! Realm().object(ofType: Subject.self, forPrimaryKey: id) ?? Subject(value: ["id" : id, "abbreviation" : abbreviation])
        if let name = json["descrformal"].string { subject.name = name }
        return subject
    }
}
