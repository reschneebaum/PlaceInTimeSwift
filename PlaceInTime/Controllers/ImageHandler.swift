//
//  ImageHandler.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/13/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import Firebase

class ImageHandler: NSObject {

    let viewController: UIViewController
    let user: User
    let trip: Trip
    let event: Event
    let storageRef: FIRStorageReference
    let ref: FIRDatabaseReference

    var imageSelected: UIImage? = nil


    init(viewController: UIViewController, user: User, trip: Trip, event: Event) {
        self.viewController = viewController
        self.user = user
        self.trip = trip
        self.event = event
        self.storageRef = FIRStorage.storage().reference(forURL: "images")
                                                        .child(event.key!)
        self.ref = FIRDatabase.database().reference(fromURL: "events")
                                                        .child(user.id)
                                                        .child(trip.key!)
                                                        .child(event.key!)
                                                        .child("images")
    }

    func showImagePickerAlert() {
        let alert = UIAlertController(title: "add new image?",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "from camera",
                                      style: .default) { _ in
            self.chooseImageFromCamera()
        })
        alert.addAction(UIAlertAction(title: "from library",
                                      style: .default) { _ in
            self.chooserImageFromPhotos()
        })
        viewController.present(alert,
                               animated: true,
                               completion: nil)
    }

    func uploadImageData(_ data: Data) {
        let id = ref.childByAutoId().key
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"

        storageRef.child(id).put(data, metadata: metadata) { metadata, error in
            guard error == nil else {
                self.viewController.errorAlert(
                    error!.localizedDescription, completion: nil)
                return
            }

            if let url = metadata?.downloadURL()?.absoluteString {
                self.addImageUrl(url, for: id)
            }
        }
    }

    private func addImageUrl(_ url: String, for key: String) {
        ref.child(key).setValue(url) { error, ref in
            guard error == nil else { return }

            print("success - url added")
        }
    }

    private func chooseImageFromCamera() {
        guard UIImagePickerController.isCameraDeviceAvailable(.rear) ||
              UIImagePickerController.isCameraDeviceAvailable(.front) else {
            viewController.errorAlert("no camera available", completion: nil)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = true
        picker.delegate = self

        viewController.present(picker, animated: true, completion: nil)
    }

    private func chooserImageFromPhotos() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self

        viewController.present(picker, animated: true, completion: nil)
    }

}

extension ImageHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            imageSelected = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageSelected = possibleImage
        }

        if let image = imageSelected,
            let data = UIImageJPEGRepresentation(image, 0.8) {
            uploadImageData(data)
            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageSelected = nil
        viewController.dismiss(animated: true, completion: nil)
    }
}
