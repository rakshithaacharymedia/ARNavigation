//
//  ConstarintLayout.swift
//  DemoApp
//
//  Created by rakshitha on 29/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit

class ConstraintLayout {
    var bottom: NSLayoutConstraint?
    var right: NSLayoutConstraint?
    var left: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    
   private func activateConstraint(bottomConstraint: Bool, rightConstraint: Bool, leftConstraint: Bool, heightConstraint: Bool) {
        bottom?.isActive = bottomConstraint
        right?.isActive = rightConstraint
        left?.isActive = leftConstraint
        height?.isActive = heightConstraint
    }
    
    func setContraint(containerView: UIView, height: CGFloat, constraintView: UIView, bottom: CGFloat) {
        activateConstraint(bottomConstraint: false, rightConstraint: false, leftConstraint: false, heightConstraint: false)
        constraintView.translatesAutoresizingMaskIntoConstraints = false
        self.bottom = constraintView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: bottom)
        self.height = constraintView.heightAnchor.constraint(equalToConstant: height)
        self.left = constraintView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 0)
        self.right = constraintView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        activateConstraint(bottomConstraint: true, rightConstraint: true, leftConstraint: true, heightConstraint: true)
    }
}
