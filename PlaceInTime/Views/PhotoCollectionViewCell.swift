//
//  PhotoCollectionViewCell.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/12/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    static let id = "PhotoCollectionViewCell"

    @IBOutlet private weak var imageView: UIImageView!

    func setImage(_ image: UIImage?, orUrlString string: String?) {
        if let image = image {
            imageView.image = image
        } else if let urlString = string,
            let url = URL(string: urlString) {

            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    imageView.image = image
                }

            } catch {
                print("error setting image = \(error)")
            }

        }
    }
}
