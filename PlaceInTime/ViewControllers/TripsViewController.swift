//
//  TripsViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import Firebase

class TripsViewController: UIViewController {

    var trips: [Trip] = []
    var indexPath: IndexPath?
    var currentUser: User?

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var logoutButton: UIBarButtonItem! {
        didSet {
            logoutButton.setTitleTextAttributes(
                navButtonAttributes, for: .normal)
        }
    }

    fileprivate let cellID = "TripTableViewCell"
    fileprivate var ref: FIRDatabaseReference?

    private var observer: UInt?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = currentUser else { return print("error: no user") }
        ref = FIRDatabase.database().reference().child("trips").child("\(user.id)")
        observeUserTrips()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.isHidden = true
    }

    func observeUserTrips() {
        observer = ref?.observe(.value, with: { snapshot in
            var userTrips: [Trip] = []

            for child in snapshot.children {
                guard let childSnap = child as? FIRDataSnapshot else {
                    return print("error parsing child values")
                }

                print("key: \(childSnap.key)")
                print("value: \(childSnap.value)")

                let trip = Trip(snapshot: childSnap)
                userTrips.append(trip)
            }

            self.trips = userTrips
            self.tableView.reloadData()

        }, withCancel: { error in
            print("unable to retrieve trips for user: \(error)")
        })
    }

    func deleteTrip(_ trip: Trip) {
        ref?.child(trip.key!).removeValue { error, _ in
            guard error == nil else { return print("error: \(error)") }
            print("trip deleted")
        }
    }
    
    @IBAction func onAddButtonTapped(_ sender: UIBarButtonItem) {
        let destination = storyboard?.instantiateViewController(withIdentifier: AddTripViewController.storyboardId) as! AddTripViewController
        destination.user = currentUser
        present(destination, animated: true, completion: nil)
    }

    @IBAction func onLogoutButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "LogoutUnwindSegue", sender: self)

        } catch { print("logout error = \(error)") }
    }

    deinit {
        if let observerHandle = observer {
            ref?.removeObserver(withHandle: observerHandle)
        }
    }
}

// MARK: - UITableViewDataSource
extension TripsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let trip = trips[indexPath.row]
        configureCell(cell, with: trip)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Trip"
    }
}

// MARK: - UITableViewDelegate
extension TripsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let trip = trips[indexPath.row]
        let eventsVC = storyboard?.instantiateViewController(withIdentifier: EventsViewController.storyboardId) as! EventsViewController
        eventsVC.trip = trip
        eventsVC.user = currentUser
        navigationController?.show(eventsVC, sender: self)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.text = "Select a Trip"
        header.textLabel?.font = UIFont(name: "Avenir Next", size: 18)
        header.textLabel?.textAlignment = .center
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.tintCellBackground
            cell.textLabel?.backgroundColor = .clear
            cell.detailTextLabel?.backgroundColor = .clear
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]

        if editingStyle == .delete {
            let alert = UIAlertController(
                title: "Delete Trip?",
                message: "Are you sure you want to delete this trip and its associated events? This action cannot be undone.",
                preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { _ in
                self.deleteTrip(trip)
            }
            alert.addAction(deleteAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)

            present(alert, animated: true, completion: nil)
        }
    }
}

fileprivate extension TripsViewController {

    func configureCell(_ cell: UITableViewCell, with trip: Trip) {
        cell.textLabel?.text = trip.name
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
        cell.detailTextLabel?.text = trip.dateString
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 12)

        if let imageString = trip.imageString {
            cell.imageView?.image = UIImage(named: imageString)
        } else {
            cell.imageView?.image = UIImage(named: "path_map")
        }
    }
}
