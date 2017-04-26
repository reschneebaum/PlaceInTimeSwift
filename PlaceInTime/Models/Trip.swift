//
//  Trip.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import Firebase
import MapKit

struct Trip {
    var name: String
    var dateString: String
    var city: String
    var state: String
    var country: String
    var placemark: CLPlacemark?
    var locationString: String
    var imageString: String?
    var date: Date?
    var events: [Event]
    var key: String?
    var ref: FIRDatabaseReference?
    var latitude: Double
    var longitude: Double

    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        dateString = snapshotValue["date"] as! String
        locationString = snapshotValue["location"] as! String
        city = snapshotValue["city"] as! String
        state = snapshotValue["state"] as! String
        country = snapshotValue["country"] as! String
        latitude = snapshotValue["latitude"] as? Double ?? 41.89374
        longitude = snapshotValue["longitude"] as? Double ?? -87.63533
        ref = snapshot.ref
        events = []
    }

    init(dictionary: [String: AnyObject], key: String? = nil, ref: FIRDatabaseReference? = nil) {
        name = dictionary["name"] as! String
        dateString = dictionary["date"] as! String
        locationString = dictionary["location"] as! String
        city = dictionary["city"] as! String
        state = dictionary["city"] as! String
        country = dictionary["country"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        events = []

        self.key = key
        self.ref = ref
    }

    init(name: String, date: Date, placemark: CLPlacemark, imageString: String? = nil) {
        self.name = name
        self.date = date
        self.dateString = Formatter.date.string(from: date) 
        self.placemark = placemark
        self.city = placemark.locality ?? ""
        self.state = placemark.administrativeArea ?? ""
        self.country = placemark.country ?? ""
        self.locationString = "\(city), \(state), \(country)"
        self.imageString = imageString
        self.events = []

        latitude = placemark.location?.coordinate.latitude ?? 0
        longitude = placemark.location?.coordinate.longitude ?? 0
    }

    mutating func addEvents(_ events: [Event]) {
        self.events.append(contentsOf: events)
    }
}

// MARK: - FirebaseModel
extension Trip: FirebaseModel {

    func toAnyObject() -> Any {
        return [
            "name": name,
            "date": dateString,
            "location": locationString,
            "city": city,
            "state": state,
            "country": country,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
