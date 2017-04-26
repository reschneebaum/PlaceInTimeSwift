//
//  Event.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import MapKit
import Firebase

struct Event {
    var name: String
    var description: String
    var locationString: String
    var latitude: Double
    var longitude: Double
    var valence: Int
    var date: Date?
    var dateString: String
    var key: String?
    var ref: FIRDatabaseReference?
    var coordinate: CLLocationCoordinate2D?
    var images: [EventImage] = []

    init(name: String, description: String, locationString: String,
         valence: Int, date: Date, coord: CLLocationCoordinate2D) {
        self.name = name
        self.description = description
        self.valence = valence
        self.date = date
        self.coordinate = coord
        self.locationString = locationString

        dateString = Formatter.date.string(from: date)
        latitude = coord.latitude
        longitude = coord.latitude
    }

    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let value = snapshot.value as! [String: AnyObject]
        name = value["name"] as! String
        description = value["description"] as! String
        dateString = value["date"] as! String
        latitude = value["latitude"] as! Double
        longitude = value["longitude"] as! Double
        valence = value["valence"] as! Int
        locationString = value["location"] as? String ?? ""
        ref = snapshot.ref
    }

    mutating func setEventImages(_ images: [EventImage]) {
        self.images = images
    }

    mutating func addImage(_ image: EventImage) {
        self.images.append(image)
    }
}

extension Event: FirebaseModel {

    func toAnyObject() -> Any {
        return [
            "name": name,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
            "valence": valence,
            "date": dateString,
            "location": locationString
        ]
    }
}
