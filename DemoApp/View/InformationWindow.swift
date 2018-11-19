//
//  InformationWindow.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit

class InformationWindow: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton! {
    didSet {
           directionButton.layer.cornerRadius = 20
           directionButton.layer.borderWidth = 2
       }
    }
    @IBOutlet weak var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
