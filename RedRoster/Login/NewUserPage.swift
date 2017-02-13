//
//  PageOneViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 4/4/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class NewUserPage: UIViewController {

    var isLastPage: Bool = false
    
    var topText: String!
    var bottomText: String!
    var imageName: String!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBAction func proceedButton(_ sender: UIButton) {
        if isLastPage {
            dismiss(animated: true, completion: nil)
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rosterRed()
        
        topLabel.text = topText ?? ""
        bottomLabel.text = bottomText ?? ""
        imageView.image = UIImage(named: imageName ?? "")
        
        proceedButton.setTitle(isLastPage ? "Start using RedRoster" : "Next", for: UIControlState())
    }
}
