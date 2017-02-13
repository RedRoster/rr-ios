//
//  Time+Location.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation

extension Date {
    static var unixTime: Date {
        return Date(timeIntervalSince1970: 0)
    }
}

/** 'Tis the season. */
enum Season: String {
    case Fall = "FA"
    case Winter = "WI"
    case Spring = "SP"
    case Summer = "SU"
    
    var description: String {
        switch self {
        case .Winter:
            return "Winter"
        case .Fall:
            return "Fall"
        case .Spring:
            return "Spring"
        case .Summer:
            return "Summer"
        }
    }
    
    var sortIndex : Int {
        switch self {
        case .Fall:
            return 0
        case .Summer:
            return 1
        case .Spring:
            return 2
        case .Winter:
            return 3
        }
    }
}

enum WeekDay: String {
    case Sunday =       "Su"
    case Monday =       "M"
    case Tuesday =      "T"
    case Wednesday =    "W"
    case Thursday =     "R"
    case Friday =       "F"
    case Saturday =     "S"
    
    var shortDescription: String {
        switch self {
        case .Sunday:
            return "Sun"
        case .Monday:
            return "Mon"
        case .Tuesday:
            return "Tue"
        case .Wednesday:
            return "Wed"
        case .Thursday:
            return "Thu"
        case .Friday:
            return "Fri"
        case .Saturday:
            return "Sat"
        }
    }
    
    var longDescription: String {
        switch self {
        case .Sunday:
            return "Sunday"
        case .Monday:
            return "Monday"
        case .Tuesday:
            return "Tuesday"
        case .Wednesday:
            return "Wednesday"
        case .Thursday:
            return "Thursday"
        case .Friday:
            return "Friday"
        case .Saturday:
            return "Saturday"
        }
    }

}
