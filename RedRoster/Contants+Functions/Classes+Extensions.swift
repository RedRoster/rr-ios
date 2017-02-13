//
//  Functions.swift
//  RedRoster
//
//  Created by Daniel Li on 3/27/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import Foundation
import UIKit

/// Subclass UIAlertController for consistent tint color
class RosterAlertController: UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.tintColor = UIColor.rosterRed()
    }
}

class SearchTextField: UITextField {
    var leftMargin: CGFloat = 0.0
    var rightMargin: CGFloat = 0.0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        newBounds.size.width -= leftMargin + rightMargin
        return newBounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        newBounds.size.width -= leftMargin + rightMargin
        return newBounds
    }
}

extension UIView {
    func fadeHide() {
        UIView.animate(withDuration: UIViewFadeShowHideDuration, animations: {
            self.alpha = 0.0
            }, completion: { Void in
                self.isHidden = true
        })
    }
    func fadeShow() {
        self.alpha = 0.0
        self.isHidden = false
        UIView.animate(withDuration: UIViewFadeShowHideDuration, animations: {
            self.alpha = 1.0
        }) 
    }
    func fadeRemoveFromSuperView() {
        UIView.animate(withDuration: UIViewFadeShowHideDuration, animations: {
            self.alpha = 0.0
            }, completion: { Void in
                self.removeFromSuperview()
        })
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

extension UINavigationController {
    func setTheme() {
        navigationBar.barTintColor = UIColor.navigationBarColor()
        navigationBar.tintColor = UIColor.white
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        extendedLayoutIncludesOpaqueBars = true
    }
}

extension UIViewController {
    func displaySignInMessage() {
        let alertController = RosterAlertController(title: "You need to be signed in.", message: "Only signed in users can see reviews and students.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func alert(errorMessage: String, completion: (() -> Void)?) {
        let alertController = RosterAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { Void in
            completion?()
            })
        present(alertController, animated: true, completion: nil)
    }
    
    func fadeCells(_ cells: [UITableViewCell]) {
        for (index, cell) in cells.enumerated() {
            UIView.animate(withDuration: RosterCellFadeDuration, delay: RosterCellFadeDelay * Double(index), options: [.allowUserInteraction], animations: {
                cell.alpha = 1.0
                }, completion: nil)
        }
    }
}

extension String {
    func alphanumeric() -> String{
        let charactersToRemove = CharacterSet.alphanumerics.inverted
        return components(separatedBy: charactersToRemove).joined(separator: "")
    }
}
