//
//  Notification.swift
//  RedRoster
//
//  Created by Daniel Li on 5/30/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import UIKit

struct Notification {
    var content: String
    var image: UIImage?
    var action: String?
    init(content: String, image: UIImage? = nil, action: String? = nil) {
        self.content = content
        self.image = image
        self.action = action
    }
}