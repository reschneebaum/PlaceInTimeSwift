//
//  LandmarkHandler.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/9/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import MapKit

class LandmarkHandler {

    var location: CLLocation

    init(location: CLLocation) {
        self.location = location
    }

    func searchForLandmarks(completion: @escaping ([Landmark]?) -> Void) {
        var landmarks: [Landmark] = []

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "landmarks"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil else {
                print("landmark search error: \(error)")
                completion(nil)
                return
            }
            guard let response = response else {
                print("landmark search error: nil response")
                completion(nil)
                return
            }

            for mapItem in response.mapItems {
                let landmark = Landmark(mapItem: mapItem)
                landmarks.append(landmark)
            }

            completion(self.sort(landmarks: landmarks))
        }
    }

    func sort(landmarks: [Landmark]) -> [Landmark] {
        var mutableLandmarks = landmarks
        mutableLandmarks.sort { (lhs, rhs) -> Bool in
            return lhs.name < rhs.name
        }
        return mutableLandmarks
    }
}
