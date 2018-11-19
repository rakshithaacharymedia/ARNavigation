//
//  LocatioManger.swift
//  DemoApp
//
//  Created by rakshitha on 17/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManagerHandler {
    static let sharedInstance = LocationManagerHandler()
    let locationManager = CLLocationManager()

    func requestLocationAuthorization(success: @escaping(SucessCllocationManager), failure: @escaping(FailureHandler)) {
        let locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                failure(AlertConstants.locationServiceErrorMessage)
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500
        } else {
          failure(AlertConstants.locationServiceErrorMessage)
        }
        success(locationManager)
    }
}
