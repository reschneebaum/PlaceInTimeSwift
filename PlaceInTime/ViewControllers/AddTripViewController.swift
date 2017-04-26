//
//  AddTripViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AddTripViewController: UIViewController {

    var user: User!

    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var cityTextField: UITextField!
    @IBOutlet fileprivate weak var stateTextField: UITextField!
    @IBOutlet fileprivate weak var countryTextField: UITextField!
    @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem! {
        didSet {
            cancelButton.setTitleTextAttributes(
                toolbarButtonAttributes, for: .normal)
        }
    }
    @IBOutlet fileprivate weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.setTitleTextAttributes(
                toolbarButtonAttributes, for: .normal)
        }
    }
    @IBOutlet fileprivate weak var datePicker: UIDatePicker!

    fileprivate var textFields: [UITextField] = []
    fileprivate var locationManager: CLLocationManager?
    fileprivate var locationPlacemark: CLPlacemark?
    fileprivate var currentLocation: CLLocation?
    fileprivate var userLocation: CLLocation?
    fileprivate var newTrip: Trip?
    fileprivate var ref: FIRDatabaseReference?


    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [cityTextField, stateTextField, countryTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.5,
                                    longitudeDelta: 0.5)
        let coordinate = CLLocationCoordinate2D(latitude: 41.89374,
                                                  longitude: -87.63533)
        let region = MKCoordinateRegion(center: coordinate,
                                        span: span)
        mapView.setRegion(region, animated: false)

        guard let user = user else { return }
        ref = FIRDatabase.database().reference().child("trips").child(user.id)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        textFields.forEach { textField in
            textField.resignFirstResponder()
        }
    }

    @IBAction func onCurrentLocationButtonTapped(_ sender: UIButton) {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    @IBAction func onCancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSaveButtonTapped(_ sender: UIBarButtonItem) {
        var complete = true
        textFields.forEach { textField in
            if !textField.hasText { complete = false }
        }
        guard complete else {
            return errorAlert("Please complete all fields", completion: nil)
        }

        performForwardGeocoding()
    }

    func addNewTrip() {
        guard let placemark = locationPlacemark,
            let city = placemark.locality,
            let state = placemark.administrativeArea,
            let country = placemark.country else { return }

        self.newTrip = Trip(name: "\(city), \(state), \(country)",
                            date: datePicker.date,
                            placemark: placemark)

        ref = FIRDatabase.database().reference().child("trips").child(user.id)
        ref?.childByAutoId().setValue(
            newTrip!.toAnyObject()) { error, ref in
                self.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension AddTripViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFields.last {
            textField.endEditing(true)
        } else {
            for i in 0..<textFields.count {
                if textField == textFields[i] {
                    textFields[i+1].becomeFirstResponder()
                }
            }
        }
        return true
    }
}

// MARK: - CLLocationManagerDelegate
extension AddTripViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 200
                && location.verticalAccuracy < 200 {
                locationManager?.stopUpdatingLocation()
                currentLocation = location
                reverseGeocode(location)
            }
            userLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error: \(error)")
    }
}

// MARK: - Geocoder
extension AddTripViewController: Geocoder {

    func performForwardGeocoding() {
        guard let city = cityTextField.text,
            let state = stateTextField.text,
            let country = countryTextField.text else { return print("missing field") }
        let locationString = "\(city) \(state) \(country)"
        forwardGeocode(from: locationString) { placemarks in
            self.locationPlacemark = placemarks.first
            self.addNewTrip()
        }
    }

    func reverseGeocode(_ location: CLLocation) {
        reverseGeocode(from: location) { placemarks in
            guard let placemark = placemarks.last else { return }
            self.cityTextField.text = placemark.locality
            self.stateTextField.text = placemark.administrativeArea
            self.countryTextField.text = placemark.country
        }
    }
}

extension AddTripViewController: MKMapViewDelegate {}
