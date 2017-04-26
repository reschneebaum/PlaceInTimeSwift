//
//  EventImage.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/14/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import Firebase

struct EventImage {
    var id: String
    var urlString: String
    var image: UIImage?
    var ref: FIRDatabaseReference

    init(snapshot: FIRDataSnapshot) {
        let value = snapshot.value as! [String: AnyObject]
        ref = snapshot.ref
        id = snapshot.key
        urlString = value["url"] as! String

        do {
            if let url = URL(string: urlString) {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.image = image
                }
            }
        } catch {
            print("error = \(error)")
        }
    }
}
