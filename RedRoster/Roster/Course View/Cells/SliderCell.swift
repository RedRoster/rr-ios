//
//  SliderCell.swift
//  RedRoster
//
//  Created by Daniel Li on 5/29/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class SliderCell: UITableViewCell {

    var index: Int!
    var delegate: RatingsDelegate?
    
    @IBOutlet weak var slider: UISlider!
    @IBAction func sliderChanged(_ sender: UISlider) {
        slider.setValue(Float(Int(slider.value + 0.5)), animated: false)
        ratingLabel.text = "\(Int(slider.value))/5"
        delegate?.ratingDidChange(index, value: slider.value)
    }
    
    @IBOutlet weak var ratingLabel: UILabel!
    
}
