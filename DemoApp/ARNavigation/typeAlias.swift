//
//  typeAlias.swift
//  DemoApp
//
//  Created by rakshitha on 13/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

// MARK: - typealias for api call
typealias SuccessHandlerDict = ([String: Any]) -> Void
typealias FailureHandler = (String) -> Void
typealias SuccessHandlerBool = (Bool) -> Void
typealias SuccessHandlerPlace = ([Place]) -> Void
typealias SuccessHandlerImage = (UIImage) -> Void
typealias SuccessHandlerCordinate = (CLLocationCoordinate2D) -> Void
typealias SuccessHandlerStep = (String, [Step], [String: String]) -> Void
typealias SucessCllocationManager = (CLLocationManager) -> Void
typealias SuccessHandlerOnlyStep = ([Step]) -> Void
