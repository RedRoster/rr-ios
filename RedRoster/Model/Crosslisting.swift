//
//  Crosslisting.swift
//  RedRoster
//
//  Created by Daniel Li on 7/19/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Crosslisting: Object {
    dynamic var subject: String = ""
    dynamic var number: Int = 0
    
    static func create(_ json: JSON) -> Crosslisting {
        let crosslisting = Crosslisting()
        crosslisting.subject = json["subject"].stringValue
        crosslisting.number = Int(json["catalogNbr"].stringValue) ?? 0
        return crosslisting
    }
    
    var shortHand: String {
        return "\(subject) \(number)"
    }
}
