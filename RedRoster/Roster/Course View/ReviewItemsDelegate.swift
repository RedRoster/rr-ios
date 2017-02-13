//
//  ReviewItemsDelegate.swift
//  RedRoster
//
//  Created by Daniel Li on 5/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation

protocol RatingsDelegate: class {
    func ratingDidChange(_ index: Int, value: Float)
}
