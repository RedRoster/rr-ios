//
//  UserCell.swift
//  RedRoster
//
//  Created by Daniel Li on 5/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    func configure(_ user: User) {
        backgroundColor = UIColor.rosterCellBackgroundColor()
        
        nameLabel.text = user.fullName
        nameLabel.textColor = UIColor.rosterCellTitleColor()
        
        emailLabel.text = user.netID ?? user.email
        emailLabel.textColor = UIColor.rosterCellSubtitleColor()
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        
        profileImageView.isHidden = false
        if let urlString = user.imageURL,
            let url = URL(string: urlString) {
            profileImageView.hnk_setImageFromURL(url)
        } else if let imageURL = URL(string: "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/s1024/photo.jpg") {
            profileImageView.hnk_setImageFromURL(imageURL)
        } else {
            profileImageView.isHidden = true
        }
        
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        selectedBackgroundView = background

    }
    
}
