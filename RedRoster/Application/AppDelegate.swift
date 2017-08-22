//
//  AppDelegate.swift
//  RedRoster
//
//  Created by Daniel Li on 3/24/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit
import GoogleSignIn
import RealmSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?
    var tabBarController: UITabBarController!
    let notificationCenter = NotificationCenter.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Appearance
        setupAppearances()
        
        // Initialize window and storyboard
        window = UIWindow(frame: UIScreen.main.bounds)
        storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Configure sign-in
        GIDSignIn.sharedInstance().clientID = "519838439998-5bkv3suacje3s5okc6feoeqpjhnd1iom.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().hostedDomain = "cornell.edu"
        
        let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = configuration
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
        window?.rootViewController = presentTabBarController()
        
        window?.makeKeyAndVisible()
        window?.tintColor = UIColor.rosterRed()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    // MARK: - Google Sign-In
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            NSLog("Google sign in failed: \(error)")
            notificationCenter.post(name: Foundation.Notification.Name(rawValue: SignInFailedNotification), object: nil, userInfo: ["error" : error])
            return
        }
        
        if user.hostedDomain != "cornell.edu" && user.profile.email != "redrostertester@gmail.com" {
            
            let error = NSError(domain: "RedRosterDomain", code: -55, userInfo: [NSLocalizedDescriptionKey : "Only users with Cornell University emails may sign in."])
            notificationCenter.post(name: Foundation.Notification.Name(rawValue: SignInFailedNotification), object: nil, userInfo: ["error" : error])
            
            return
        }
        
        NetworkManager.validateSignIn { (newUser, error) in
            if error != nil {
                print("Backend sign in failed")
                self.notificationCenter.post(name: Foundation.Notification.Name(rawValue: SignInFailedNotification), object: nil, userInfo: ["error" : error!])
            } else {
                self.presentSignedInTabs()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Schedule.self))
                realm.delete(realm.objects(Element.self))
            }
        } catch let error {
            print("Error while deleting all schedules from realm: \(error)")
        }
        
        presentTabBarController()
    }
    
    // MARK: - Application Flow
    
    func presentTabBarController() -> UITabBarController {
        
        // Initialize View Controllers
        
        let rosterViewController = UINavigationController(rootViewController: TermListViewController())
        rosterViewController.tabBarItem = UITabBarItem(title: "Roster", image: UIImage(named: "student"), tag: 0)
        
        let loginViewController = storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
        let loginNavigationController = UINavigationController(rootViewController: loginViewController)
        loginNavigationController.tabBarItem = UITabBarItem(title: "Login", image: UIImage(named: "login"), tag: 0)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([rosterViewController, loginNavigationController].flatMap { $0 }, animated: false)
        tabBarController.delegate = self
        tabBarController.tabBar.isTranslucent = false
        self.tabBarController = tabBarController
        window?.rootViewController = tabBarController
        
        return tabBarController
    }
    
    func presentSignedInTabs() {
        
        let rosterViewController = UINavigationController(rootViewController: TermListViewController())
        rosterViewController.tabBarItem = UITabBarItem(title: "Roster", image: UIImage(named: "student"), tag: 0)
        
        let scheduleViewController = UINavigationController(rootViewController: ScheduleListViewController())
        scheduleViewController.tabBarItem = UITabBarItem(title: "Schedules", image: UIImage(named: "calendar"), tag: 1)
        
        let peopleViewController = UINavigationController(rootViewController: PeopleViewController(searchBase: .serverSide))
        peopleViewController.tabBarItem = UITabBarItem(title: "People", image: UIImage(named: "people"), tag: 2)
        
        let settingsViewController = storyboard!.instantiateViewController(withIdentifier: "SettingsTableViewController")
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "gear"), tag: 3)
        
        tabBarController.setViewControllers([rosterViewController, scheduleViewController, peopleViewController, settingsNavigationController], animated: false)
    }
    
    // MARK: - Appearance
    
    func setupAppearances() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.white
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.5)
        UIPageControl.appearance().backgroundColor = UIColor.rosterRed()
    }
    
    // MARK: - Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() && Date().timeIntervalSince1970 > GIDSignIn.sharedInstance().currentUser.authentication.idTokenExpirationDate.timeIntervalSince1970 {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

