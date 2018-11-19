//
//  PathInformationWindow.swift
//  DemoApp
//
//  Created by rakshitha on 15/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit

class PathInformationWindow: UIView {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
