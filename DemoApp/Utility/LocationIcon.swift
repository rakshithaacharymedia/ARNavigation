//
//  LocationIcon.swift
//  DemoApp
//
//  Created by rakshitha on 26/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit

class LocationIcon {
    
    static func getImagefromUrl(url: String, success: @escaping(SuccessHandlerImage), failure: @escaping(FailureHandler)) {
        if let imageFromCache = imageCache.object(forKey: url as NSString) as? UIImage {
            success(imageFromCache)
        } else {
           getImageFromWeb(url: url, success: { image in
                success(image)
            }, failure: { alertString in
                failure(alertString)
            })
        }
    }
    
   static private func getImageFromWeb(url: String, success: @escaping(SuccessHandlerImage), failure: @escaping(FailureHandler)) {
        guard let iconUrl = URL(string: url) else {
            DispatchQueue.main.async {
                failure(AlertConstants.incorrectURLErrorMessage)
            }
            return
        }
        let task = URLSession(configuration: .default).dataTask(with: iconUrl) { data, _, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    failure(AlertConstants.apiErrorMessage)
                }
                return
            }
            guard let data = data, let image = (UIImage(data: data)) else {
                DispatchQueue.main.async {
                    failure(AlertConstants.apiErrorMessage)
                }
                return
                
            }
            let resizeImage = image.resized(newSize: CGSize(width: 20, height: 20))
            imageCache.setObject(resizeImage, forKey: url as NSString)
            DispatchQueue.main.async {
                success(resizeImage)
            }
        }
        task.resume()
    }

}
