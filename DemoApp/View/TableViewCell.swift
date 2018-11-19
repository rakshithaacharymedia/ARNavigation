//
//  TableViewCell.swift
//  DemoApp
//
//  Created by rakshitha on 24/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.numberOfLines = 0
            addressLabel.lineBreakMode = .byWordWrapping
        }
    }
    var result: GMSAutocompletePrediction? {
        didSet {
            nameLabel.attributedText = result?.attributedPrimaryText
            addressLabel.attributedText = result?.attributedFullText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
