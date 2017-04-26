//
//  PITUtils.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    class var storyboardId: String {
        return "\(self)"
    }

    func errorAlert(_ message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .default,
                                      handler: nil))

        present(alert, animated: true, completion: completion)
    }

    func goToRoot(user: User?) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let navVC = storyboard.instantiateViewController(
            withIdentifier: "MainNavigationController") as! UINavigationController
        let tripsVC = storyboard.instantiateViewController(
            withIdentifier: TripsViewController.storyboardId) as! TripsViewController

        if let user = user {
            tripsVC.currentUser = user
        }

        navVC.navigationBar.barTintColor = UIColor.navBarBackground
        navVC.navigationBar.tintColor = UIColor.navBarTint
        navVC.setBackButton()
        navVC.setViewControllers([tripsVC], animated: false)
        
        present(navVC, animated: true, completion: nil)
    }

    func setBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"),
                                         style: .plain,
                                         target: self,
                                         action: .back)
        navigationItem.leftBarButtonItem = backButton
    }

    @objc fileprivate func goBack() {
        let _ = navigationController?.popViewController(animated: true)
    }
}

extension UINavigationController {

    override func setBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"),
                                         style: .plain,
                                         target: self,
                                         action: .back)
        navigationItem.leftBarButtonItem = backButton
    }
}

extension Selector {
    static let back = #selector(UIViewController.goBack)
}


extension UITableView {

    func registerNib(_ identifier: String) {
        let nib = UINib(nibName: identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: identifier)
    }
}
