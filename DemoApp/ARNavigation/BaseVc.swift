//
//  AlertMaker.swift
//  DemoApp
//
//  Created by rakshitha on 11/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit

// MARK: - alert message
class BaseVc: UIViewController {
    func alert(info: String) {
            let alert = UIAlertController(title: "Alert", message: info, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
