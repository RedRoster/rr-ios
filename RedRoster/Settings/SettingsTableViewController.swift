//
//  SettingsTableViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/26/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import GoogleSignIn
import SafariServices
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var signOutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appearance
        navigationController?.setTheme()
        signOutLabel.textColor = UIColor.red
        tableView.separatorColor = UIColor.rosterCellSeparatorColor()
        tableView.backgroundColor = UIColor.rosterBackgroundColor()
    }

    // MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return GIDSignIn.sharedInstance().hasAuthInKeychain() ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            var subject: String
            var message: String
            
            switch indexPath.row {
            case 0:
                subject = "Bug Report"
                message = "Please describe the issue you're experiencing:\n\n\nIf possible, list steps to take to reproduce the issue:\n\n\n---------------\nRedRoster iOS \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")\n\(UIDevice.current.systemVersion)\n\(UIDevice.current.modelName)"
            case 1:
                subject = "Feature Request"
                message = "Please describe the feature you would like to see on RedRoster:\n\n\n\n\n"
                break
            default:
                subject = ""
                message = ""
                break
            }
            presentMailComposer(subject, message: message)
        case 1:
            switch indexPath.row {
            case 0:
                showWebPage("https://redroster.me/")
            case 1:
                showWebPage("https://redroster.me/privacy")
            case 2:
                showWebPage("https://redroster.me/acknowledgements")
            case 3:
                showWebPage("https://redroster.me/about")
            default:
                return
            }
        case 2:
            let alertController = RosterAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { Void in
                GIDSignIn.sharedInstance().disconnect()
                })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.rosterCellBackgroundColor()
        let background = UIView()
        background.backgroundColor = UIColor.rosterCellSelectionColor()
        cell.selectedBackgroundView = background
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        }
        if section == 2 {
            return "Signed in as: " + GIDSignIn.sharedInstance().currentUser.profile.email
        }
        return nil
    }
    
    func showWebPage(_ url: String) {
        guard let url = URL(string: url) else { return }
        if #available(iOS 9.0, *) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    func presentMailComposer(_ subject: String, message: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerViewController = MFMailComposeViewController()
            mailComposerViewController.mailComposeDelegate = self
            mailComposerViewController.setToRecipients(["team@redroster.me"])
            mailComposerViewController.setSubject(subject)
            mailComposerViewController.setMessageBody(message, isHTML: false)
            present(mailComposerViewController, animated: true, completion: nil)
        } else {
            alert(errorMessage: "You haven't set up your email on this device yet.", completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
