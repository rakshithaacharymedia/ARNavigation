//
//  Step.swift
//  DemoApp
//
//  Created by rakshitha on 13/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import CoreLocation

struct Step {
    var distance: String = ""
    var duration: String = ""
    var endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var locationName: String = ""
    
    func intermediateRouteInfo(_ leg: [String: Any]) -> [Step] {
        var steps = [Step] ()
        for step in leg[ApiResponseConstant.steps] as? [[String: Any]] ?? [[ :]] {
            if let location = step[ApiResponseConstant.end_location] as? [String: Any], let distance = step[ApiResponseConstant.distance] as? [String: Any], let duration = step[ApiResponseConstant.duration] as? [String: Any], let name = step[ApiResponseConstant.html_instructions] as? String {
                if let lat = location[ApiResponseConstant.lat] as? CLLocationDegrees, let lng = location[ApiResponseConstant.lng] as? CLLocationDegrees, let distanceText = distance[ApiResponseConstant.text] as? String, let durationText = duration[ApiResponseConstant.text] as? String {
                    steps.append(Step(distance: distanceText, duration: durationText, endLocation: CLLocationCoordinate2D(latitude: lat, longitude: lng), locationName: ((name).html2String)))
                }
            }
        }
        return steps
    }
}
