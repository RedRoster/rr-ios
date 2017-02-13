//
//  DetailCell.swift
//  RedRoster
//
//  Created by Daniel Li on 3/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    func configure(_ title: String, icon: UIImage?, detailTitle: String?) {
        textLabel?.text = title
        textLabel?.textColor = UIColor.rosterCellTitleColor()
        
        if let detail = detailTitle {
            detailTextLabel?.text = detail
        } else {
            detailTextLabel?.text = ""
        }
        
        detailTextLabel?.textColor = UIColor.rosterCellSubtitleColor()
        
        imageView?.image = icon
        imageView?.tintColor = UIColor.rosterIconColor()
        
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background
    }
}
