//
//  Geocoder.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/9/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit

protocol Geocoder {
    func forwardGeocode(from addressString: String,
        completion: @escaping ([CLPlacemark]) -> Void)
    func reverseGeocode(from location: CLLocation,
        completion: @escaping ([CLPlacemark]) -> Void)
}

extension Geocoder where Self: UIViewController {

    /**
     finds coordinates of user-entered location
     */
    func forwardGeocode(from addressString: String,
                        completion: @escaping ([CLPlacemark]) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            guard error == nil else {
                self.errorAlert(error!.localizedDescription, completion: nil)
                return
            }
            completion(placemarks ?? [])
        }
    }

    /**
     if user selects 'current location,' fill textfields based on current location
     */
    func reverseGeocode(from location: CLLocation,
                        completion: @escaping ([CLPlacemark]) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                self.errorAlert(error!.localizedDescription, completion: nil)
                return
            }
            completion(placemarks ?? [])
        }
    }
}
