//
//  LoginViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var activityIndicator: DGActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rosterRed()
        navigationController?.setTheme()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(settingsButtonPressed))
        navigationItem.backBarButtonItem?.title = "Login"
        
        // GIDSignIn
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Sign In Observers
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.signInFailed(_:)), name: NSNotification.Name(rawValue: SignInFailedNotification), object: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func setupLoadingView() {
        let activityIndicator = DGActivityIndicatorView(type: .threeDots, tintColor: UIColor.white)
        activityIndicator?.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
        self.activityIndicator = activityIndicator
    }
    
    func settingsButtonPressed() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController")
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    // MARK: Google Sign In
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true) {
            self.setupLoadingView()
            self.messageLabel.fadeHide()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func signInFailed(_ notification: Foundation.Notification) {
        GIDSignIn.sharedInstance().signOut()
        if let error = notification.userInfo?["error"] as? Error, error._code != -5 {
            alert(errorMessage: error.localizedDescription, completion: nil)
        }
        messageLabel.fadeShow()
        activityIndicator?.fadeRemoveFromSuperView()
    }
}
