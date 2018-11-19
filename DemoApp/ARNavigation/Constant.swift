//
//  Constant.swift
//  DemoApp
//
//  Created by rakshitha on 09/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit

let apiKey = "AIzaSyBAaConfJ3aAo0dHsUGWr5PXh3rLAPWLLw"

struct ApiResponseConstant {
    static let result = "result"
    static let results = "results"
    static let location = "location"
    static let geometry = "geometry"
    static let lat = "lat"
    static let lng = "lng"
    static let routes = "routes"
    static let overview_polyline = "overview_polyline"
    static let points = "points"
    static let legs = "legs"
    static let steps = "steps"
    static let end_location = "end_location"
    static let types = "types"
    static let name = "name"
    static let vicinity = "vicinity"
    static let icon = "icon"
    static let distance = "distance"
    static let duration = "duration"
    static let text = "text"
    static let html_instructions = "html_instructions"
    static let locationaddress = "locationaddress"
}

struct AlertConstants {
    static let locationServiceErrorMessage = "Enable location service to continue!"
    static let noPathErrorMessage = "No path found"
    static let locationDetailErrorMessage = "Could not fetch location details"
    static let  arErrorMessage = "Device does not support ArConfiguration"
    static let insertErrorMessage = "Failed to insert data into database"
    static let fetchErrorMessage = "Failed to fetch data from database"
    static let apiErrorMessage = "Api failed to fetch location detail"
    static let incorrectURLErrorMessage = "Invalid url"
    static let cameraAccessErrorMessage = "Allow camera Access to continue"
    static let responseErrorMessage = "No response"
}

struct TravelModeImage {
    static let carselect = "car_icon"
    static let carUnselect = "car_icon_unselect"
    static let walkSelect = "walk_icon"
    static let walkUnselect = "walk_icon_unselect"
}

struct UiViewDimension {
    static let yPostion = CGFloat(200)
    static let pathInfoHeight = CGFloat(75)
    static let pathInfoAnimateHeight = CGFloat(300)
    static let locationInfoHeight = CGFloat(225)
    static let locationInfoAnimatedHeight = CGFloat(423)
    static let tableHeight = CGFloat(80)
    static let animatedHeight = CGFloat(250)
}

struct ArkitNodeDimension {
    static let destinationNodeLength = CGFloat(2.0)
    static let destinationNodeWidth = CGFloat(2.0)
    static let destinationNodeHeight = CGFloat(2.0)
    static let destinationChamferRadius = CGFloat(0.5)
    static let sourceNodeLength = CGFloat(0.1)
    static let sourceNodeWidth = CGFloat(0.1)
    static let sourceNodeHeight = CGFloat(0.1)
    static let sourceChamferRadius = CGFloat(0.1)
    static let cylinderRadius = CGFloat(0.1)
    static let nodeYPosition = CGFloat(0.5)
    static let textDepth = CGFloat(0.2)
    static let textSize = CGFloat(1.0)
}

struct TextNodeConstant {
    static let direction = "Direction"
    static let distance = "Distance"
    static let duration = "Duration"
    static let destination = "Destination"
}
