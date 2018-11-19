//
//  GoogleApiUrl.swift
//  DemoApp
//
//  Created by rakshitha on 12/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation

class GoogleApiUrl {
     let baseUrl = "https://maps.googleapis.com/maps/api"
    
  // MARK: - get url
    func getNearbyPlaceUrl(latitude: Double, longitude: Double, radius: Float) -> String {
        return  "\(baseUrl)/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&key=\(apiKey)"
    }
    
    func getPlaceCordinateUrl(placeId: String) -> String {
        return "\(baseUrl)/place/details/json?placeid=\(placeId)&fields=geometry&key=\(apiKey)"
    }
    
    func getRouteUrl(source: LocationDetails, destination: LocationDetails, mode: String) -> String {
        return "\(baseUrl)/directions/json?origin=\(source.lat),\(source.lng)&destination=\(destination.lat),\(destination.lng)&mode=\(mode)&key=\(apiKey)"
    }
}
