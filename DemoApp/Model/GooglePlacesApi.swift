//
//  GooglePlacesApi.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation

class GooglePlacesApi {
    let apiurl = GoogleApiUrl()
    
    func getNearbyplace(latitude: Double, longitude: Double, radius: Float, success: @escaping (SuccessHandlerDict), failure: @escaping (FailureHandler)) {
        let urlForNearbySearch = apiurl.getNearbyPlaceUrl(latitude: latitude, longitude: longitude, radius: radius)
        let task: URLSessionDataTask?
        guard let url = URL(string: urlForNearbySearch) else { return }
        task = URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    failure(AlertConstants.apiErrorMessage)
                    return
                }
            } else {
                do {
                    if let data = data {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
                        success(json)
                    }
                } catch {
                    DispatchQueue.main.async {
                        failure(AlertConstants.locationDetailErrorMessage)
                        return
                    }
                }
            }
        }
        task?.resume()
    }
    
    //get address from given latitude and longitude
    func getAddress(latitude: Double, longitude: Double, success: @escaping(SuccessHandlerDict), failure: @escaping(FailureHandler)) {
        var locationaddress: String = ""
        var address = [String: Any]()
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    failure(AlertConstants.locationDetailErrorMessage)
                }
                return
            } else {
                if let place = placemarks?[0] {
                    if let name = place.name {
                        address[ApiResponseConstant.name] = name
                        locationaddress = name
                    }
                    if let thoroughfare = place.thoroughfare {
                        locationaddress +=  "," + thoroughfare
                    }
                    if let locality = place.locality {
                        locationaddress += "," + locality
                    }
                    if let postalcode = place.postalCode {
                        locationaddress += "-" + postalcode
                    }
                    if let administartivearea = place.administrativeArea {
                        locationaddress += "," + administartivearea
                    }
                    address[ApiResponseConstant.locationaddress] = locationaddress
                    }
                success(address)
            }
        })
    }

    func getplaceCordinate(placeId: String, success: @escaping(SuccessHandlerCordinate), failure: @escaping(FailureHandler)) {
        var placeCordinate = CLLocationCoordinate2D()
        let urlforPlaceDetail = apiurl.getPlaceCordinateUrl(placeId: placeId)
        let task: URLSessionDataTask?
        guard  let url = URL(string: urlforPlaceDetail) else { return }
        task = URLSession(configuration: .default).dataTask(with: url) { data, _, error in
           if error != nil {
            DispatchQueue.main.async {
                    failure(AlertConstants.apiErrorMessage)
                }
               return
            }
                do {
                if let data = data {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                      if let result = json[ApiResponseConstant.result] as? [String: Any] {
                        if let geometry = result[ApiResponseConstant.geometry] as? [String: Any] {
                            if let location = geometry[ApiResponseConstant.location] as? [String: Double] {
                                guard  let latitude = location[ApiResponseConstant.lat] else { return }
                                guard  let longitude = location[ApiResponseConstant.lng] else { return }
                                placeCordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            }
                         }
                        }
                       }
                    }
                    DispatchQueue.main.async {
                        success(placeCordinate)
                    }
                } catch {
                    DispatchQueue.main.async {
                        failure(AlertConstants.apiErrorMessage)
               }
            }
          }
        task?.resume()
    }
    
    func getRoute(source: LocationDetails, destination: LocationDetails, mode: String, success: @escaping(SuccessHandlerStep), failure: @escaping(FailureHandler)) {
    var steps = [Step] ()
    var routePoints: String = ""
    var dict = [String: String]()
    let task: URLSessionDataTask?
    let urlforRoute = apiurl.getRouteUrl(source: source, destination: destination, mode: mode)
    guard let url = URL(string: urlforRoute) else { return }
    task = URLSession(configuration: .default).dataTask(with: url) { data, _, error in
        if  error != nil {
            DispatchQueue.main.async {
                 failure(AlertConstants.apiErrorMessage)
            }
            return
        }
        do {
            if let data = data {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       if let routes = json[ApiResponseConstant.routes] as?NSArray {
                            if let routeDict = routes.firstObject as? [String: Any] {
                                if let overview_polyline = routeDict[ApiResponseConstant.overview_polyline] as? [String: String] {
                                    if let points = overview_polyline[ApiResponseConstant.points] {
                                        routePoints = points
                                    }
                                }
                                if let legs = routeDict[ApiResponseConstant.legs] as? [[String: Any]] {
                                    for leg in legs {
                                      if  let totalDistance = leg[ApiResponseConstant.distance] as? [String: Any], let totalDuration = leg[ApiResponseConstant.duration] as? [String: Any] {
                                             dict[ApiResponseConstant.distance] = totalDistance[ApiResponseConstant.text] as? String
                                             dict[ApiResponseConstant.duration] = totalDuration[ApiResponseConstant.text] as? String
                                        }
                                      steps = Step().intermediateRouteInfo(leg)
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                success(routePoints, steps, dict)
            }
       } catch {
        DispatchQueue.main.async {
               failure(AlertConstants.apiErrorMessage)
        }
        }
    }
    task?.resume()
   }
}
