//
//  EventDetailTableViewCell.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/13/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

protocol EditingCell {
    func switchForEditing(_ editing: Bool, save: Bool)
}

class EventDetailTableViewCell: UITableViewCell {

    static let id = "EventDetailTableViewCell"

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var textField: UITextField! {
        didSet {
            textField.alpha = 0
        }
    }
    @IBOutlet private weak var labelWidthConstraint: NSLayoutConstraint!

    func configure<D: UITextFieldDelegate>(delegate: D,
                   with field: EventDetailField, for event: Event) {
        titleLabel.text = field.labelText
        textField.delegate = delegate

        switch field {
        case .date:
            contentLabel.text = event.dateString
            textField.text = event.dateString
            textField.tag = 1
        case .location:
            contentLabel.text = event.locationString
            textField.text = event.locationString
            textField.tag = 2
            labelWidthConstraint.constant = 150

        default:
            break
        }
    }

}

extension EventDetailTableViewCell: EditingCell {

    func switchForEditing(_ editing: Bool, save: Bool = false) {
        if editing {
            UIView.animate(withDuration: 0.5) {
                self.contentLabel.alpha = 0
                self.textField.alpha = 1
            }
        } else {
            if save {
                contentLabel.text = textField.text
            }
            UIView.animate(withDuration: 0.5) {
                self.contentLabel.alpha = 1
                self.textField.alpha = 0
            }
        }
        setNeedsLayout()
    }
}

enum EventDetailField {
    case date, location, valence, description

    var labelText: String {
        switch self {
        case .date:
            return "date"
        case .location:
            return "location"
        case .valence:
            return "valence"
        case .description:
            return "description"
        }
    }
}
