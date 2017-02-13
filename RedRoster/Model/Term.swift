//
//  Term.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import RealmSwift

/** A Term represents an academic term during a season (Fall, Spring, Summer, Winter) of a given year. */
class Term: Object {
    
    var season: Season {
        let seasonSlug = slug.substring(to: slug.characters.index(slug.startIndex, offsetBy: 2))
        return Season(rawValue: seasonSlug)!
    }
    
    var year: Int {
        let yearSlug = "20" + slug.substring(from: slug.characters.index(slug.startIndex, offsetBy: 2))
        return Int(yearSlug)!
    }
    
    /// API Slug
    dynamic var slug: String = ""
    
    let subjects = List<Subject>()
    
    override static func primaryKey() -> String {
        return "slug"
    }
    
    override var description: String {
        return "\(season) \(year)"
    }
    
    static func create(_ slug: String) -> Term {
        let term: Term = try! Realm().object(ofType: Term.self, forPrimaryKey: slug) ?? Term(value: ["slug" : slug])
        return term
    }
    
}
