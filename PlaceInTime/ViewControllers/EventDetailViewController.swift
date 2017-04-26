//
//  EventDetailViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import Firebase

class EventDetailViewController: UITableViewController {

    var user: User!
    var trip: Trip!
    var event: Event!
    var imageHandler: ImageHandler!
    var ref: FIRDatabaseReference?
    // temp
    let colors: [[UIColor]] = generateRandomData()
    var storedOffsets: [Int: CGFloat] = [:]

    fileprivate var images: [EventImage] = []
    fileprivate var editingCells: [EditingCell] = []
    fileprivate var editingEvent = false


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(PhotosTableViewCell.id)
        tableView.registerNib(EventDetailTableViewCell.id)
        tableView.registerNib(EventDescriptionTableViewCell.id)
        tableView.registerNib(ButtonTableViewCell.id)

        let editButton = UIBarButtonItem(title: "edit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onEditButtonTapped(_:)))
        editButton.setTitleTextAttributes(navButtonAttributes,
                                          for: .normal)
        navigationItem.rightBarButtonItem = editButton

        guard let user = user,
            let trip = trip,
            let event = event else { return }
        imageHandler = ImageHandler(viewController: self,
                                    user: user,
                                    trip: trip,
                                    event: event)
        ref = FIRDatabase.database().reference(fromURL: "events")
                                                .child(user.id)
                                                .child(trip.key!)
                                                .child(event.key!)
    }

    func onEditButtonTapped(_ sender: UIBarButtonItem) {
        if editingEvent {
            sender.title = "cancel"
        } else {
            sender.title = "edit"
        }

        for cell in editingCells {
            cell.switchForEditing(!editingEvent, save: false)
        }
        editingEvent = !editingEvent
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            if editingEvent { return 1 }
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EventDetailTableViewCell.id,
                    for: indexPath) as! EventDetailTableViewCell
                cell.configure(delegate: self, with: .date, for: event)
                editingCells.append(cell)
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EventDetailTableViewCell.id,
                    for: indexPath) as! EventDetailTableViewCell
                cell.configure(delegate: self, with: .location, for: event)
                editingCells.append(cell)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EventDescriptionTableViewCell.id,
                    for: indexPath) as! EventDescriptionTableViewCell
                cell.configure(delegate: self, event: event)
                editingCells.append(cell)
                return cell

            default: break
            }

        case 1:
            switch indexPath.row {
            case 3:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: PhotosTableViewCell.id,
                    for: indexPath) as! PhotosTableViewCell
                return cell

            case 4:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ButtonTableViewCell.id,
                    for: indexPath) as! ButtonTableViewCell
                cell.configure(delegate: self, title: "add photo")
                return cell

            default: break
            }

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.id, for: indexPath) as! ButtonTableViewCell
            cell.configure(delegate: self, title: "save")
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PhotosTableViewCell else { return }
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PhotosTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 2):
            return UITableViewAutomaticDimension
        case (1, 1):
            return 80
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension EventDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = images[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.id,
            for: indexPath) as! PhotoCollectionViewCell
        cell.setImage(image.image, orUrlString: image.urlString)
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension EventDetailViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField,
                                reason: UITextFieldDidEndEditingReason) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: - UITextViewDelegate
extension EventDetailViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}

// MARK: - ButtonTableViewCellDelegate
extension EventDetailViewController: ButtonTableViewCellDelegate {

    func buttonTapped(_ sender: UIButton) {
        if sender.title(for: .normal) == "save" {
            for cell in editingCells {
                cell.switchForEditing(false, save: true)
                editingEvent = false
            }
        } else {
            imageHandler.showImagePickerAlert()
        }
    }
}
