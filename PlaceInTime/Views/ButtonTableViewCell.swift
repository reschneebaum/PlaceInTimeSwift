//
//  ButtonTableViewCell.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/13/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

protocol ButtonTableViewCellDelegate: class {
    func buttonTapped(_ sender: UIButton)
}

class ButtonTableViewCell: UITableViewCell {

    static let id = "ButtonTableViewCell"

    weak var delegate: ButtonTableViewCellDelegate?

    @IBOutlet private weak var button: UIButton!


    func configure<D: ButtonTableViewCellDelegate>(delegate: D,
                   title: String) {
        self.delegate = delegate
        button.setTitle(title, for: .normal)
    }

    @IBAction func onButtonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender)
    }
    
}
