//
//  ArViewController.swift
//  DemoApp
//
//  Created by rakshitha on 03/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import GoogleMaps
import AVFoundation

class ARPathViewController: BaseVc {
    @IBOutlet weak var sourceDestinationLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    var source: CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    var sourcePosition = SCNVector3()
    var destinationPosition = SCNVector3()
    var stepData = [Step]()
    var name: String?
    var sourceDetail: LocationDetails?
    var destinationDetail: LocationDetails?
    var mode: String?
    var apiKey = ""
    
   // MARK: - override method
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraAccess()
        sourceDestinationLabel.text = name
    }
    
    // MARK: - Inialization
    private func getIntermediateCordinates() {
        if let sourceDetail = sourceDetail, let destinationDetail = destinationDetail, let mode = mode {
        source = CLLocationCoordinate2D(latitude: sourceDetail.lat, longitude: sourceDetail.lng)
        destination = CLLocationCoordinate2D(latitude: destinationDetail.lat, longitude: destinationDetail.lng)
        GetIntermediateCordinate.getCordinates(source: sourceDetail, destination: destinationDetail, mode: mode, success: { [weak self] steps in
            guard let self = self else { return }
              self.stepData = steps
              self.arConfigurationInitialize()
              self.arViewSetup()
          }, failure: { alertString in
                self.alert(info: alertString)
        })
      }
    }
    
    private func checkCameraAccess() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
             getIntermediateCordinates()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.getIntermediateCordinates()
                } else {
                    self.alert(info: AlertConstants.cameraAccessErrorMessage)
                }
            })
        }
    }
    
    private func arConfigurationInitialize() {
        if  ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravityAndHeading
            sceneView.session.run(configuration)
        } else {
            alert(info: AlertConstants.arErrorMessage)
        }
    }
    
    private func arViewSetup() {
        placeSourceNode()
        if let source = source, let destination = destination {
            for intermediateLocation in stepData.enumerated() {
                var text = "\(TextNodeConstant.direction) : " + intermediateLocation.element.locationName
                text += "\n \(TextNodeConstant.distance) :" + intermediateLocation.element.distance
                text += " \n \(TextNodeConstant.duration) : " + intermediateLocation.element.duration
                placeDestinationNode(source: source, destination: intermediateLocation.element.endLocation, text: text)
            }
            placeDestinationNode(source: source, destination: destination, text: TextNodeConstant.destination)
        }
    }
    
   // MARK: - Outlet methods
    @IBAction private func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Core methods
    private func placeSourceNode() {
        let box = SCNBox(width: ArkitNodeDimension.sourceNodeWidth, height: ArkitNodeDimension.sourceNodeHeight, length: ArkitNodeDimension.sourceNodeLength, chamferRadius: ArkitNodeDimension.sourceChamferRadius)
        let sourceNode = SCNNode(geometry: box)
        sourceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        sourceNode.position = SCNVector3(0, -(ArkitNodeDimension.nodeYPosition), 0)
        sceneView.scene.rootNode.addChildNode(sourceNode)
    }
    
    private func distanceBetweenCordinate(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> Double {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distance = sourceLocation.distance(from: destinationLocation)
        return distance
    }
    
    private func placeDestinationNode(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, text: String) {
        let distance = distanceBetweenCordinate(source: source, destination: destination)
        let destinationNode = SCNNode(geometry: intermediateNodeGeometry())
        let  transformationMatrix = transformMatrix(source: source, destination: destination, distance: distance, text: text)
        destinationNode.transform = transformationMatrix
        sceneView.scene.rootNode.addChildNode(destinationNode)
        placeCylinder(source: sourcePosition, destination: destinationNode.position)
        let directionTextNode = placeDirectionText(textPosition: destinationNode.position, text: text)
        destinationNode.addChildNode(directionTextNode)
        sourcePosition = destinationNode.position
    }
    
    private func intermediateNodeGeometry() -> SCNBox {
        let intermediateBox = SCNBox(width: ArkitNodeDimension.destinationNodeWidth, height: ArkitNodeDimension.destinationNodeHeight, length: ArkitNodeDimension.destinationNodeLength, chamferRadius: ArkitNodeDimension.destinationChamferRadius)
        intermediateBox.firstMaterial?.diffuse.contents = UIColor.purple
        return intermediateBox
    }
    
    private func transformMatrix(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, distance: Double, text: String) -> SCNMatrix4 {
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
        let rotation = SCNMatrix4MakeRotation(-1 * GLKMathDegreesToRadians(Float(GMSGeometryHeading(source, destination))), 0, 1, 0)
        let transformationMatrix = SCNMatrix4Mult(translation, rotation)
        return (transformationMatrix)
    }
    
    private func placeCylinder(source: SCNVector3, destination: SCNVector3) {
        let  height = source.distance(receiver: destination)
        let  cylinder = SCNCylinder(radius: ArkitNodeDimension.cylinderRadius, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3((source.x + destination.x) / 2, Float(-(ArkitNodeDimension.nodeYPosition)), (source.z + destination.z) / 2)
        let dirVector = SCNVector3Make(destination.x - source.x, destination.y - source.y, destination.z - source.z)
        let yAngle = atan(dirVector.x / dirVector.z)
        node.eulerAngles.x = .pi / 2
        node.eulerAngles.y = yAngle
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func getintermediateNodeText(text: String) -> SCNText {
        let intermediateNodeText = SCNText(string: text, extrusionDepth: ArkitNodeDimension.textDepth)
        intermediateNodeText.font = UIFont(name: "Optima", size: ArkitNodeDimension.textSize)
        intermediateNodeText.firstMaterial?.diffuse.contents = UIColor.red
        intermediateNodeText.containerFrame = CGRect(x: 0.0, y: 0.0, width: 20, height: 10)
        intermediateNodeText.isWrapped = true
        return intermediateNodeText
    }
    
    private func placeDirectionText(textPosition: SCNVector3, text: String) -> SCNNode {
        let textNode = SCNNode(geometry: getintermediateNodeText(text: text))
        textNode.constraints = [SCNBillboardConstraint()]
        return textNode
    }
    
    private func getApiKey() {
        apiKey = "AIzaSyBAaConfJ3aAo0dHsUGWr5PXh3rLAPWLLw"
    }
}
