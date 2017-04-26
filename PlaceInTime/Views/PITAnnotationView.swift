//
//  PITAnnotationView.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/10/17.
//  thanks to this answer: http://stackoverflow.com/a/25877372/607876
//

import UIKit
import MapKit

typealias ViewBlock = (_ view: UIView) -> Bool

extension UIView {
    func loopViewHierarchyBlock(_ block: ViewBlock?) {
        if block?(self) ?? true {
            for subview in subviews {
                subview.loopViewHierarchyBlock(block)
            }
        }
    }
}

class PITAnnotationView: MKAnnotationView {

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        if isSelected {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // MKAnnotationViews only have subviews if they've been selected.
        // short-circuit if there's nothing to loop over
        if !isSelected {
            return
        }

        // set custom font
        loopViewHierarchyBlock { (view: UIView) -> Bool in
            if let label = view as? UILabel {
                label.setFont(size: 13)
                return false
            }
            return true
        }
    }

}


