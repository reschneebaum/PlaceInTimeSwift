//
//  EventDescriptionTableViewCell.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/13/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

class EventDescriptionTableViewCell: UITableViewCell {

    static let id = "EventDescriptionTableViewCell"

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.alpha = 0
        }
    }

    func configure<D: UITextViewDelegate>(delegate: D,
                   with field: EventDetailField = .description, event: Event) {
        descriptionTextView.delegate = delegate
        descriptionTextView.text = event.description
        descriptionLabel.text = event.description
        titleLabel.text = field.labelText
    }

}

extension EventDescriptionTableViewCell: EditingCell {

    func switchForEditing(_ editing: Bool, save: Bool = false) {
        if editing {
            UIView.animate(withDuration: 0.5) {
                self.descriptionLabel.alpha = 0
                self.descriptionTextView.alpha = 1
            }
        } else {
            if save {
                descriptionLabel.text = descriptionTextView.text
            }
            UIView.animate(withDuration: 0.5) {
                self.descriptionLabel.alpha = 1
                self.descriptionTextView.alpha = 0
            }
        }
        setNeedsLayout()
    }
}
