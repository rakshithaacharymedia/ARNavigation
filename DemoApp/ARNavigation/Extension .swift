//
//  Extension .swift
//  DemoApp
//
//  Created by rakshitha on 08/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit
import GoogleMaps

// MARK: - resize image
extension UIImage {
    func resized(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return newImage
    }
}

// MARK: - distance between 2 cordinates
extension SCNVector3 {
    func distance(receiver: SCNVector3) -> Float {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        if distance < 0 {
            return distance * -1
        } else {
            return distance
        }
    }
}

// MARK: - convert html to string
extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            guard let rawData = data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return nil }
            return try NSAttributedString(data: rawData,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

// MARK: - calculate newRadius when zoom level changes
extension GMSMapView {
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.center
        let centerCoordinate = self.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCoordinate() -> CLLocationCoordinate2D {
        let topCordinate = self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), from: self)
        let point = self.projection.coordinate(for: topCordinate)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCoordinate = self.getTopCoordinate()
        let topLocation = CLLocation(latitude: topCoordinate.latitude, longitude: topCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topLocation))
        return round(radius)
    }
}
