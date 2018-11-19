//
//  DataStore.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataStore {
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func insert(nearbyPlaceDict: [String: Any], success: @escaping (SuccessHandlerPlace), failure: @escaping(FailureHandler)) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = context
        privateContext.perform {
            if let result = nearbyPlaceDict[ApiResponseConstant.results] as? [[String: Any]] {
                for obj in result.enumerated() {
                    if let entity = NSEntityDescription.insertNewObject(forEntityName: "Place", into: privateContext) as? Place {
                        if let dict = obj.element as? [String: Any] {
                            if let geometry = dict[ApiResponseConstant.geometry] as? [String: Any] {
                                if let location = geometry[ApiResponseConstant.location] as? [String: Double] {
                                    if let latitude = location[ApiResponseConstant.lat] {
                                        entity.latitude = latitude
                                        
                                    }
                                    if let longitude = location[ApiResponseConstant.lng] {
                                        entity.longitude = longitude
                                    }
                                }
                                if let type = dict[ApiResponseConstant.types] as? [String] {
                                    entity.typeofPlace = type[0]
                                }
                                if let name = dict[ApiResponseConstant.name] as? String {
                                    entity.name = name
                                }
                                if let icon = dict[ApiResponseConstant.icon]  as? String {
                                    entity.icon = icon
                                }
                                if let vicinity = dict[ApiResponseConstant.vicinity]  as? String {
                                    entity.vicinity = vicinity
                                }
                            }
                        }
                    }
                }
            }
            do {
                try privateContext.save()
                    self.fetch(success: { nearbyPlace in
                        DispatchQueue.main.async {
                             success(nearbyPlace)
                        }
                    }, failure: { alertString in
                        DispatchQueue.main.async {
                             failure(alertString)
                        }
                    })
                
            } catch {
                DispatchQueue.main.async {
                    failure(AlertConstants.fetchErrorMessage)
                }
            }
        }
 }
    
    private func fetch(success: @escaping(SuccessHandlerPlace), failure: @escaping(FailureHandler)) {
        let request = NSFetchRequest<Place>(entityName: "Place")
        var nearbyPlace = [Place]()
        do {
            if let result = try context?.fetch(request) {
                nearbyPlace = result
            }
            DispatchQueue.main.async {
               success(nearbyPlace)
            }
          } catch {
            DispatchQueue.main.async {
                failure(AlertConstants.fetchErrorMessage)
            }
        }
    }
}
