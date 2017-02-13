//
//  ColorScheme.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: Global Colors
    
    static func rosterRed() -> UIColor {
        return UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
    }
    
    static func rosterRedDark() -> UIColor {
        return UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
    }
    
    static func navigationBarColor() -> UIColor {
        return rosterRed()
    }
    
    // MARK: Side Menu
    
    static func sideMenuBackgroundColor() -> UIColor {
        return UIColor(red:0.16, green:0.18, blue:0.20, alpha:1.00)
    }
    
    static func sideMenuTextColor() -> UIColor {
        return UIColor.white
    }
    
    // MARK: Roster and Schedule
    
    static func rosterBackgroundColor() -> UIColor {
        return UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    }
    
    static func rosterCellSelectionColor() -> UIColor {
        return white
    }
    
    static func rosterCellSelectionColorDark() -> UIColor {
        return UIColor(white: 1.0, alpha: 0.1)
    }
    
    static func rosterHeaderColor() -> UIColor {
        return rosterBackgroundColor()
    }
    
    static func rosterHeaderTitleColor() -> UIColor {
        return rosterRed()
    }
    
    static func rosterCellBackgroundColor() -> UIColor {
        return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    }
    
    static func rosterCellSeparatorColor() -> UIColor {
        return UIColor(white: 0.89, alpha: 1.0)
    }
    
    static func rosterCellSeparatorColorDark() -> UIColor {
        return UIColor(white: 0.3, alpha: 1.0)
    }
    
    static func rosterCellTitleColor() -> UIColor {
        return darkGray
    }
    
    static func rosterCellSubtitleColor() -> UIColor {
        return gray
    }
    
    static func rosterSearchBackgroundColor() -> UIColor {
        return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    }
    
    static func rosterIconColor() -> UIColor {
        return rosterRed()
    }
    
    static func backgroundImageDarkColor() -> UIColor {
        return UIColor(white: 0.0, alpha: 0.65)
    }
    
    // MARK: Calendar
    
    static func calendarBarBackgroundColor() -> UIColor {
        return UIColor(white: 0.0, alpha: 0.4)
    }
    
    static func calendarBarTextColor() -> UIColor {
        return UIColor.gray
    }
    
    static func calendarBarSelectedTextColor() -> UIColor {
        return rosterRed()
    }
    
    static func calendarBarSelectedViewColor() -> UIColor {
        return UIColor.white
    }
    
    static func calendarBackgroundColor() -> UIColor {
        return UIColor(white: 0.0, alpha: 0.7)
    }
    
    static func calendarHourSeparatorColor() -> UIColor {
        return UIColor(white: 1.0, alpha: 0.4)
    }
    
    static func calendarHourLabelColor() -> UIColor {
        return UIColor(white: 1.0, alpha: 0.6)
    }
    
    static func calendarEventBackgroundColor() -> UIColor {
        return UIColor(white: 0.8, alpha: 0.6)
    }
    
    
}
