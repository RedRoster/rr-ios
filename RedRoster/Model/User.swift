//
//  Person.swift
//  RedRoster
//
//  Created by Daniel Li on 4/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleSignIn

/** A User represents a user of RedRoster */
struct User {
    
    /// The Current Signed In User
    static var currentUser: User {
        let profile = GIDSignIn.sharedInstance().currentUser.profile
        let defaults = UserDefaults.standard
        return User(id: defaults.integer(forKey: "currentUserId"), firstName: profile!.givenName, lastName: profile!.familyName, email: profile!.email, imageURL: profile!.imageURL(withDimension: 512).absoluteString)
    }
    
    /// This User's unique identifier
    var id: Int
    
    /// This User's first name
    var firstName: String
    
    /// This User's last name
    var lastName: String
    
    /// This User's email address
    var email: String
    
    /// This User's profile image URL
    var imageURL: String?
    
    var netID: String? {
        if let range = email.range(of: "@cornell.edu") {
            return email.substring(to: range.lowerBound)
        } else {
            return nil
        }
    }
    
    /// The full name of this User
    var fullName: String {
        return firstName + " " + lastName
    }
    
    init(json: JSON) {
        id = json["id"].intValue
        firstName = json["fname"].stringValue.capitalized
        lastName = json["lname"].stringValue.capitalized
        email = json["email"].stringValue
        imageURL = json["picture_url"].string
    }
    
    init(id: Int, firstName: String, lastName: String, email: String, imageURL: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.imageURL = imageURL
    }
}
