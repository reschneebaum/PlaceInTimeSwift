//
//  LandmarkAnnotation.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/9/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit

class LandmarkAnnotation: MKPointAnnotation {}

class UserEventAnnotation: MKPointAnnotation {
    var valence: Int?
    var event: Event?

    init(event: Event) {
        super.init()
        configure(with: event)
    }

    func configure(with event: Event) {
        self.event = event
        self.valence = event.valence

        title = event.name
        subtitle = event.dateString.uppercased()
        coordinate = CLLocationCoordinate2D(
            latitude: event.latitude, longitude: event.longitude)
    }
}
