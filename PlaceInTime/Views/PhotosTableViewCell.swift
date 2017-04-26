//
//  PhotosTableViewCell.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/12/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {

    static let id = "PhotosTableViewCell"

    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        set {
            collectionView.contentOffset.x = newValue
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: PhotoCollectionViewCell.id,
                            bundle: nil)
            collectionView.register(nib,
                forCellWithReuseIdentifier: PhotoCollectionViewCell.id)
        }
    }

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        collectionView.dataSource = dataSourceDelegate
        collectionView.delegate = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }

    
}
