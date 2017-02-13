//
//  Element.swift
//  RedRoster
//
//  Created by Daniel Li on 4/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

/** An Element is a part of a Schedule that a user can add, edit or delete. */
class Element: Object {
    
    /// Unique identifier for the Element
    dynamic var id: Int = 0
    
    /// Whether there is a collision
    dynamic var collision: Bool = false
    
    /// The Section that belongs to this element
    dynamic var section: Section?
    
    /// The id of the Course that belongs to this element
    dynamic var courseId: Int = 0
    
    /// The date this element was created
    dynamic var creationDate: Date = .unixTime
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(_ json: JSON, courseId: Int, readOnly: Bool, offerNumber: Int) -> Element {
        let json = json["schedule_element"]
        let id = json["id"].int!
        let element: Element = readOnly ? Element(value: ["id" : id]) : try! Realm().object(ofType: Element.self, forPrimaryKey: id) ?? Element(value: ["id" : id])
        
        if let collision = json["collision"].bool { element.collision = collision }
        element.section = Section.create(json["section"], readOnly: readOnly, offerNumber: offerNumber)
        element.courseId = courseId
        
        if let creationDateString = json["created_at"].string,
            let creationDate = RailsDateFormatter.date(from: creationDateString) {
            element.creationDate = creationDate
        }
        
        return element
    }
}
