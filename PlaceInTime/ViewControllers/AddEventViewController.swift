//
//  AddEventViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AddEventViewController: UIViewController {

    var user: User!
    var trip: Trip!
    var coordinate: CLLocationCoordinate2D!
    var event: Event?
    var location: String?

    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    @IBOutlet fileprivate weak var slider: UISlider!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.alpha = 0.8
        }
    }
    @IBOutlet fileprivate weak var descriptionTextView: UITextView!
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
    fileprivate var datePicker: UIDatePicker?
    private var ref: FIRDatabaseReference?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()

        guard let user = user,
            let trip = trip,
            let coordinate = coordinate else { return }
        ref = FIRDatabase.database().reference()
            .child("events").child(user.id).child(trip.key!)

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5))
        mapView.setRegion(region, animated: false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        nameTextField.endEditing(true)
        dateTextField.endEditing(true)
        descriptionTextView.endEditing(true)
    }

    @IBAction func onCancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSaveButtonTapped(_ sender: UIBarButtonItem) {
        saveNewEvent()
    }

    func saveNewEvent() {
        guard let name = nameTextField.text,
            let date = datePicker?.date,
            let desc = descriptionTextView.text,
            let location = location else {
            return errorAlert(
                "Please complete all fields", completion: nil)
        }

        let event = Event(
            name: name, description: desc, locationString: location,
            valence: Int(slider.value), date: date, coord: coordinate)
        ref?.childByAutoId().setValue(event.toAnyObject()) { error, _ in
            guard error == nil else {
                return self.errorAlert(
                    error!.localizedDescription, completion: nil)
            }

            self.dismiss(animated: true, completion: nil)
        }
    }
}


// MARK: - UITextFieldDelegate
extension AddEventViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nameTextField {
            dateTextField.becomeFirstResponder()
        } else if textField == dateTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension AddEventViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) { 
            self.descriptionLabel.alpha = 0
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        if !textView.hasText {
            UIView.animate(withDuration: 0.5) {
                self.descriptionLabel.alpha = 0.8
            }
        }
    }
}

// MARK: - private
fileprivate extension AddEventViewController {

    func setupTextFields() {
        descriptionTextView.delegate = self
        nameTextField.delegate = self
        dateTextField.delegate = self

        let toolbar = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        toolbar.layer.position = CGPoint(
            x: view.frame.size.width/2,
            y: view.frame.size.height - 20.0)
        toolbar.barStyle = .default
        toolbar.barTintColor = UIColor.navBarBackground
        toolbar.tintColor = UIColor.navBarTint

        let cancelButton = UIBarButtonItem(
            title: "cancel", style: .plain, target: self, action: .cancel)
        cancelButton.setTitleTextAttributes(
            toolbarButtonAttributes, for: .normal)
        let saveButton = UIBarButtonItem(
            title: "save", style: .plain, target: self, action: .save)
        saveButton.setTitleTextAttributes(
            toolbarButtonAttributes, for: .normal)
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems(
            [cancelButton, flexSpace, saveButton],
            animated: false)

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(
            self, action: .datePickerChanged, for: .valueChanged)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
    }

    @objc func toolbarCancelButtonTapped() {
        dateTextField.resignFirstResponder()
        dateTextField.text = ""
    }

    @objc func toolbarSaveButtonTapped() {
        dateTextField.resignFirstResponder()
    }

    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        dateTextField.text = Formatter.date.string(
            from: datePicker.date)
    }
}

private extension Selector {
    static let cancel = #selector(
        AddEventViewController.toolbarCancelButtonTapped)
    static let save = #selector(
        AddEventViewController.toolbarSaveButtonTapped)
    static let datePickerChanged = #selector(AddEventViewController.datePickerDidChange(_:))
}
