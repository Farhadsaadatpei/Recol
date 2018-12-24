//
//  HeaderCollectionViewCell.swift
//  recol
//
//  Created by Brian on 10/18/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit
import EFCountingLabel

class HeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var intCount: EFCountingLabel!
    @IBOutlet weak var presentationType: UILabel!
}
