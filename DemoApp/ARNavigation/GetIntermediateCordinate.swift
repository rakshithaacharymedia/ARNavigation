//
//  GetIntermediateCordinate.swift
//  DemoApp
//
//  Created by rakshitha on 06/11/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation

class GetIntermediateCordinate {
    
    static func getCordinates(source: LocationDetails, destination: LocationDetails, mode: String, success: @escaping(SuccessHandlerOnlyStep), failure: @escaping(FailureHandler)) {
        var steps = [Step] ()
        let task: URLSessionDataTask?
        let urlforRoute = GoogleApiUrl().getRouteUrl(source: source, destination: destination, mode: mode)
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
                                if let legs = routeDict[ApiResponseConstant.legs] as? [[String: Any]] {
                                    for leg in legs {
                                       steps = Step().intermediateRouteInfo(leg)
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    success( steps)
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
