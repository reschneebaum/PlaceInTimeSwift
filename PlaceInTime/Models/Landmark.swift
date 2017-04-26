//
//  Landmark.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import MapKit

struct Landmark {
    var name: String
    var placemark: CLPlacemark?
    var annotation: LandmarkAnnotation?

    init(mapItem: MKMapItem) {
        name = mapItem.name ?? ""
        placemark = mapItem.placemark

        annotation = LandmarkAnnotation()
        annotation?.title = name
        annotation?.coordinate = mapItem.placemark.coordinate
    }

    init(name: String) {
        self.name = name
    }
}
