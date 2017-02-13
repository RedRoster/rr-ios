
//
//  TermPickerViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 5/1/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import PickerView

class TermPickerViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let parent = (presentingViewController as? UINavigationController)?.topViewController
        if let parent = parent as? NewScheduleViewController {
            parent.termChoiceIndex = termChoiceIndex!
            parent.tableView.reloadData()
        } else if let parent = parent as? AddReviewViewController {
            parent.termChoiceIndex = termChoiceIndex
            parent.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var pickerView: PickerView!
    
    init() {
        super.init(nibName: "TermPickerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var termChoiceIndex: Int?
    var terms: [Term]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if termChoiceIndex == nil {
            termChoiceIndex = 0
        }
        
        setupPickerView()
        setupButtons()
        view.backgroundColor = UIColor.rosterBackgroundColor()
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectionStyle = .none
        pickerView.backgroundColor = UIColor.clear
        pickerView.currentSelectedRow = termChoiceIndex
    }
    
    func setupButtons() {
        cancelButton.tintColor = UIColor.rosterRed()
        doneButton.tintColor = UIColor.rosterRed()
    }
}

extension TermPickerViewController: PickerViewDataSource, PickerViewDelegate {
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return terms.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return terms[index].description
    }
    
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int, index: Int) {
        termChoiceIndex = index
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 55.0
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        if highlighted {
            label.font = UIFont.systemFont(ofSize: 24.0)
            label.textColor = UIColor.rosterRed()
        } else {
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = UIColor.gray
        }
    }
}

