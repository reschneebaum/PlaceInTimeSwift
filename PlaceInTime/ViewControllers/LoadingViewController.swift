//
//  LoadingViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/12/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import Firebase

class LoadingViewController: UIViewController {

    var loggedInUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener { _, user in
            if let user = user {
                self.getLoggedInUser(user)
            } else {
                self.performSegue(withIdentifier: "LoginRootSegue",
                                  sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripsRootSegue",
            let navVC = segue.destination as? UINavigationController,
            let tripsVC = navVC.viewControllers[0] as? TripsViewController {
                navVC.setBackButton()
                tripsVC.currentUser = loggedInUser
        }
    }


    func getLoggedInUser(_ user: FIRUser) {
        let user = User(authData: user)
        loggedInUser = user

        performSegue(withIdentifier: "TripsRootSegue", sender: self)
    }
}
