//
//  Formatter.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/9/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation

struct Formatter {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
}
