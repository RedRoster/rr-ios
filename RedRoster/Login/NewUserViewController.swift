//
//  NewUserViewController.swift
//  RedRoster
//
//  Created by Daniel Li on 4/3/16.
//  Copyright © 2016 dantheli. All rights reserved.
//

import UIKit

class NewUserViewController: UIPageViewController {
    
    fileprivate(set) var pages: [UIViewController] = []
    
    func createNewUserPage(_ topText: String?, bottomText: String?, imageName: String?, isLastPage: Bool = false) -> NewUserPage? {
        guard let newUserPage = storyboard?.instantiateViewController(withIdentifier: "NewUserPage") as? NewUserPage else { return nil }
        newUserPage.topText = topText
        newUserPage.bottomText = bottomText
        newUserPage.imageName = imageName
        newUserPage.isLastPage = isLastPage
        return newUserPage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        view.backgroundColor = UIColor.rosterRed()
        
        // Instantiate pages
        pages = [createNewUserPage("View courses and add them to your schedule",
                                    bottomText: "See reviews by former students or write your own",
                                    imageName: nil) ?? NewUserPage(),
                 createNewUserPage("Edit your profile and view your schedules",
                                    bottomText: "Swipe to the right on any screen to get to the menu",
                                    imageName: nil,
                                    isLastPage: true) ?? NewUserPage()]
        
        // Set first page
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
}

extension NewUserViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.index(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 && previousIndex < pages.count else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.index(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        guard nextIndex >= 0 && nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = pages.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
