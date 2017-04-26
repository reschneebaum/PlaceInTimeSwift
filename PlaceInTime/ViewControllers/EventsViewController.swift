//
//  EventsViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit
import Firebase

private let userEventCell = "UserEventTableViewCell"
private let landmarkCell = "LandmarkTableViewCell"

class EventsViewController: UIViewController {

    var user: User!
    var trip: Trip!

    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate var addButton: UIBarButtonItem! {
        didSet {
            addButton.setTitleTextAttributes(
                navButtonAttributes, for: .normal)
            navigationItem.rightBarButtonItem = addButton
        }
    }

    fileprivate var userEvents: [Event] = []
    fileprivate var landmarks: [Landmark] = []
    fileprivate var locationManager: CLLocationManager?
    fileprivate var landmarkHandler: LandmarkHandler?
    private var ref: FIRDatabaseReference?
    private var observer: UInt?


    override func viewDidLoad() {
        super.viewDidLoad()

        title = trip.name
        setBackButton()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.isHidden = true
        tableView.alpha = 0

        guard let user = user,
            let trip = trip else { return print("error: no trip") }
        ref = FIRDatabase.database().reference()
            .child("events").child(user.id).child(trip.key!)

        setupMapView()
    }

    func observeEvents() {
        observer = ref?.observe(.value, with: { snapshot in
            var events: [Event] = []
            for child in snapshot.children {
                guard let childSnap = child as? FIRDataSnapshot else { return }
                let event = Event(snapshot: childSnap)
                events.append(event)
            }

            self.userEvents = events.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.name < rhs.name
            })
            self.tableView.reloadData()

        }, withCancel: { error in
            print("error observing trips: \(error)")
        })
    }

    func displayEventAnnotation(_ event: Event) {
        let annotation = UserEventAnnotation(event: event)
        mapView.addAnnotation(annotation)

        print("user annotation = \(annotation)")
        print("user annotation title = \(annotation.title)")
        print("user annotation valence = \(annotation.valence)")
        print("user annotation lat = \(annotation.event?.latitude)")
        print("user annotation lon = \(annotation.event?.longitude)")

    }

    func deleteEvent(_ event: Event) {
        ref?.child(event.key!).removeValue { error, _ in
            guard error == nil else { return print("error deleting event") }
            print("event deleted")
        }
    }

    func fetchLandmarks(for location: CLLocation) {
        landmarkHandler = LandmarkHandler(location: location)
        landmarkHandler?.searchForLandmarks { [weak self] landmarks in
            guard let strongSelf = self,
                let landmarks = landmarks else { return }

            strongSelf.landmarks = landmarks
            strongSelf.tableView.reloadData()

            for landmark in landmarks {
                strongSelf.mapView.addAnnotation(landmark.annotation!)
            }

            for event in strongSelf.userEvents {
                strongSelf.displayEventAnnotation(event)
            }
        }
    }

    func handleLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state != .began { return }

        // convert long press touch point to CLLocationCoordinate2D
        let touchPoint = recognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        stringFromReverseGeocode(from: CLLocation(
            latitude: touchMapCoordinate.latitude,
            longitude: touchMapCoordinate.longitude)) { locationString in

                // continue to fill in event detail
                let eventVC = self.storyboard?.instantiateViewController(
                    withIdentifier: AddEventViewController.storyboardId) as! AddEventViewController
                eventVC.user = self.user
                eventVC.trip = self.trip
                eventVC.coordinate = touchMapCoordinate
                eventVC.location = locationString
                self.present(eventVC, animated: true, completion: nil)
        }
    }

    func viewEventDetail(_ event: Event) {
        let eventVC = storyboard?.instantiateViewController(withIdentifier: EventDetailViewController.storyboardId) as! EventDetailViewController
        eventVC.event = event
        navigationController?.show(eventVC, sender: self)
    }

    func viewLandmarkInfo(_ landmark: Landmark) {
        let webVC = storyboard?.instantiateViewController(withIdentifier: WebViewController.storyboardId) as! WebViewController
        webVC.landmark = landmark
        navigationController?.show(webVC, sender: self)
    }

    @IBAction func onSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.mapView.alpha = 0
                self.tableView.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.mapView.alpha = 1
                self.tableView.alpha = 0
            })
        }
    }

    @IBAction func onAddButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "To add a new event, press and hold on the map,\n or enter the address below:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Street Address"
        }
        alert.addTextField { textField in
            textField.placeholder = "City, State, Country"
            textField.text = self.trip.locationString
        }
        alert.addAction(UIAlertAction(title: "continue", style: .default) { _ in
            guard let addressString = alert.textFields?[0].text,
                let cityString = alert.textFields?[1].text else { return }
            self.beginForwardGeocoding(from: "\(addressString) \(cityString)")
        })
        alert.addAction(UIAlertAction(title: "back to map", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    deinit {
        if let obsHandle = observer {
            ref?.removeObserver(withHandle: obsHandle)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userEvents.count
        } else {
            return landmarks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: userEventCell, for: indexPath)
            let event = userEvents[indexPath.row]
            configure(cell: cell, with: event)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: landmarkCell, for: indexPath)
            let event = landmarks[indexPath.row]
            configure(cell: cell, with: event)
            return cell

        default: fatalError("unexpected section")
        }
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var destination: UIViewController
        if indexPath.section == 0 {
            let event = userEvents[indexPath.row]
            destination = storyboard?.instantiateViewController(withIdentifier: EventDetailViewController.storyboardId) as! EventDetailViewController
            (destination as! EventDetailViewController).event = event
            (destination as! EventDetailViewController).user = user
            (destination as! EventDetailViewController).trip = trip
        } else {
            let event = landmarks[indexPath.row]
            destination = storyboard?.instantiateViewController(withIdentifier: WebViewController.storyboardId) as! WebViewController
            (destination as! WebViewController).landmark = event
        }
        navigationController?.show(destination, sender: self)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "personal events & landmarks"
        } else {
            return "historical events & landmarks"
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75.0
        } else {
            return 60.0
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = userEvents[indexPath.row]
            let alert = UIAlertController(
                title: "Delete Event?",
                message: "Are you sure you want to delete this location and its associated event information? This action cannot be undone.",
                preferredStyle: .alert)
            let deleteAction = UIAlertAction(
                title: "Delete", style: .default) { _ in
                    self.deleteEvent(event)
            }
            alert.addAction(deleteAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Geocoder
extension EventsViewController: Geocoder {

    func beginForwardGeocoding(from address: String) {
        forwardGeocode(from: address) { placemarks in
            // convert user address into CLLocationCoordinate
            guard let placemark = placemarks.first,
                let coordinate = placemark.location?.coordinate else { return }

            // continue to add event details
            let eventVC = self.storyboard?.instantiateViewController(withIdentifier: AddEventViewController.storyboardId) as! AddEventViewController
            eventVC.user = self.user
            eventVC.trip = self.trip
            eventVC.coordinate = coordinate
            eventVC.location = address
            self.present(eventVC, animated: true, completion: nil)
        }
    }

    func stringFromReverseGeocode(from location: CLLocation,
                                  completion: @escaping (String) -> Void) {
        reverseGeocode(from: location) { placemarks in
            if let placemark = placemarks.first {
                let address = placemark.thoroughfare ?? ""
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""

                completion("\(address) \(city) \(state) \(country)")
                return
            }

            completion("")
        }
    }
}

// MARK: - MKMapViewDelegate
extension EventsViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: "AnnotationView") as? PITAnnotationView
            ?? PITAnnotationView(annotation: annotation,
                                 reuseIdentifier: "AnnotationView")
        annotationView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)

        // user location = default blue circle
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }

        let cropRect = CGRect(x: 0, y: 0, width: 35, height: 35)
        let calloutImageView = UIImageView(frame: cropRect)
        calloutImageView.clipsToBounds = true
        annotationView.canShowCallout = true
        annotationView.leftCalloutAccessoryView = calloutImageView
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        print("annotationView = \(annotationView)")

        // if user event, draw custom pin on map
        if let userAnnot = annotation as? UserEventAnnotation,
            let valence = userAnnot.valence {

            print("valence = \(valence)")

            switch valence {
            case 1:
                annotationView.image = UIImage(named: "red_pin")
            case 2:
                annotationView.image = UIImage(named: "orange_pin")
            case 3:
                annotationView.image = UIImage(named: "green_pin")
            case 4:
                annotationView.image = UIImage(named: "blue_pin")
            case 5:
                annotationView.image = UIImage(named: "purple_pin")
            default:
                break
            }

            // draw map icon on annotation view
            calloutImageView.image = UIImage(named: "path_map")
            annotationView.tag = 10
        } else {
            // otherwise draw camera icon for callout, landmark for map
            calloutImageView.image = UIImage(named: "camera")
            annotationView.image = UIImage(named: "landmark_small")
            annotationView.tag = 20
        }

        print("annotation tag = \(annotationView.tag)")
        print("annotation class = \(annotation)")
        print("annotationView name = \(annotationView.annotation?.title)")


        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.tag {
        case 10:
            let annotation = view.annotation as! UserEventAnnotation
            if let event = annotation.event {
                viewEventDetail(event)
            }

        case 20:
            let annotation = view.annotation as! LandmarkAnnotation
            let landmark = Landmark(name: annotation.title!)
            viewLandmarkInfo(landmark)

        default:
            return
        }
    }
}

// MARK - CLLocationManagerDelegate
extension EventsViewController: CLLocationManagerDelegate {}


// MARK: - private
fileprivate extension EventsViewController {

    func setupMapView() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.alpha = 1

        let location = CLLocation(latitude: trip.latitude,
                                  longitude: trip.longitude)
        mapView.setRegion(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)),
            animated: true)
        fetchLandmarks(for: location)

        let pressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.handleLongPress))
        pressRecognizer.minimumPressDuration = 1.2
        mapView.addGestureRecognizer(pressRecognizer)

        observeEvents()
    }

    func configure(cell: UITableViewCell, with userEvent: Event) {
        cell.textLabel?.text = userEvent.name
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
        cell.detailTextLabel?.text = userEvent.dateString
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 12)
        cell.imageView?.image = UIImage(named: "pin")
    }

    func configure(cell: UITableViewCell, with landmark: Landmark) {
        cell.textLabel?.text = landmark.name
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 16)
        cell.imageView?.image = UIImage(named: "landmark")
    }
}
