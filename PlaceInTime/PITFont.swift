//
//  PITFont.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/10/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

extension UILabel {

    func setFont(size: CGFloat) {
        font = UIFont(
            name: "Avenir Next", size: size)
    }
}

extension UIButton {

    func setFont(size: CGFloat) {
        titleLabel?.font = UIFont(
            name: "Avenir Next", size: size)
    }
}
