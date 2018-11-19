//
//  ViewController.swift
//  DemoApp
//
//  Created by rakshitha on 19/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit

let imageCache = NSCache<NSString, AnyObject>()

class MapViewController: BaseVc {
    @IBOutlet private weak var walkModeButton: UIButton!
    @IBOutlet private weak var driveModeButton: UIButton!
    @IBOutlet private weak var arkitNavigationButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private  weak var directionInfoView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private  var containerView: UIView!
    @IBOutlet private weak var sourceTextField: UITextField! {
        didSet {
            sourceTextField.layer.borderColor = UIColor.black.cgColor
            sourceTextField.layer.borderWidth = 1.0
        }
    }
    @IBOutlet private weak var destinationTextField: UITextField! {
        didSet {
            destinationTextField.layer.borderColor = UIColor.black.cgColor
            destinationTextField.layer.borderWidth = 1.0
        }
    }
    let googleApi = GooglePlacesApi()
    let coreDataObject = DataStore()
    var locationManager: CLLocationManager?
    var locationinformationView: InformationWindow? {
        didSet {
            locationinformationView?.layer.borderColor = UIColor.white.cgColor
            locationinformationView?.layer.borderWidth = 2.0
        }
    }
    var pathInformationView: PathInformationWindow?
    var radius: CLLocationDistance = 0.0
    var mapView: GMSMapView?
    var destinationMarker = GMSMarker()
    var camera = GMSCameraPosition()
    var arrayAddress = [GMSAutocompletePrediction]()
    var polyline: GMSPolyline?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var source = LocationDetails()
    var destination = LocationDetails()
    var mode: String = TravelMode.walk.rawValue
    var steps = [Step]()
    var pathInformationConstraint = ConstraintLayout()
    var locationInformationConstraint = ConstraintLayout()
    
   // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerInitialize()
        mapInitialize()
        resultsViewControllerInitialize()
        searchBarInitialize()
        activityIndicatorInitialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVc = segue.destination as?  ARPathViewController {
            destinationVc.name = source.name + " To " +  destination.name
            destinationVc.sourceDetail = source
            destinationVc.destinationDetail = destination
            destinationVc.mode = mode
        }
    }
    
    // MARK: - Controller initialization
    private func locationManagerInitialize() {
        LocationManagerHandler.sharedInstance.requestLocationAuthorization(success: { [weak self] locationManager in
            guard let self = self else { return }
            self.locationManager = locationManager
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }, failure: { alerString in
           self.alert(info: alerString)
        })
    }
    
    private func resultsViewControllerInitialize() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.tintColor = UIColor.white
        resultsViewController?.primaryTextHighlightColor = UIColor.blue
        resultsViewController?.primaryTextColor = UIColor.darkText
    }
    
    // MARK: - UI initialization
    private func mapInitialize() {
        mapView = GMSMapView()
        mapView?.frame = UIScreen.main.bounds
        mapView?.delegate = self
        containerView.addSubview(mapView ?? GMSMapView())
    }
    
    private func activityIndicatorInitialize() {
        mapView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func searchBarInitialize() {
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Enter Location"
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.barTintColor = UIColor.red
        searchController?.searchBar.backgroundImage = UIImage()
        searchController?.searchBar.delegate = self
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    private func animateView(constraintView: UIView, constraintLayout: ConstraintLayout, height: CGFloat) {
        constraintLayout.setContraint(containerView: containerView, height: height, constraintView: constraintView, bottom: UiViewDimension.animatedHeight)
        UIView.animate(withDuration: 0.5) {
            self.containerView.layoutIfNeeded()
        }
    }
    
    // MARK: - IBAction methods
    @IBAction private func closeDirectionInfoView(_ sender: Any) {
        directionInfoView.isHidden = true
        navigationController?.isNavigationBarHidden = false
        tableView.isHidden = true
        mapView?.frame = UIScreen.main.bounds
        if let polyline = polyline {
            polyline.map = nil
        }
        destinationMarker.map = nil
        mode = TravelMode.walk.rawValue
        searchBarInitialize()
        mapView?.delegate = self
        if let pathInformation = pathInformationView {
         animateView(constraintView: pathInformation, constraintLayout: pathInformationConstraint, height: 75)
        }
        mapView?.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction private func travelModeSelected(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        if button.tag == TravelModeButtonTag.drive.rawValue {
            mode = TravelMode.drive.rawValue
            setModeButton(driveImage: TravelModeImage.carselect, driveColor: UIColor.white, walkImage: TravelModeImage.walkUnselect, walkColor: UIColor.black)
        } else {
            mode = TravelMode.walk.rawValue
            setModeButton(driveImage: TravelModeImage.carUnselect, driveColor: UIColor.black, walkImage: TravelModeImage.walkSelect, walkColor: UIColor.white)
        }
        getdirection()
    }
    
    // MARK: - target functions
    @objc private func directionButtonClicked(sender: UIButton) {
        if let locationinformationView = locationinformationView {
            animateView(constraintView: locationinformationView, constraintLayout: locationInformationConstraint, height: UiViewDimension.locationInfoHeight)
        }
        directionInfoView.isHidden = false
        destinationTextField.text = destination.name
        mapView?.delegate = nil
        arkitNavigationButton.isEnabled = false
        navigationController?.isNavigationBarHidden = true
        if let mapView = self.mapView {
            destinationMarker = setMarker(lat: destination.lat, long: destination.lng, name: destination.name, address: " ", mapView: mapView)
            destinationMarker.map = mapView
        }
        if mapView?.frame.origin.y == UIScreen.main.bounds.origin.y {
            if let width = mapView?.bounds.width, let height = mapView?.frame.height {
                mapView?.frame = CGRect(x: 0, y: directionInfoView.bounds.height + directionInfoView.frame.origin.y, width: width, height: height - directionInfoView.bounds.height)
            }
        }
        setModeButton(driveImage: TravelModeImage.carUnselect, driveColor: UIColor.black, walkImage: TravelModeImage.walkSelect, walkColor: UIColor.white)
        getdirection()
    }
    
    @objc private func closeLocationInformationView(sender: UIButton) {
        if let view = locationinformationView {
            animateView(constraintView: view, constraintLayout: locationInformationConstraint, height: UiViewDimension.locationInfoHeight)
        }
        destinationMarker.map = nil
        searchBarInitialize()
    }
    
    // MARK: - Mapview methods
    private func getCurrentLocation() {
        guard let lat = locationManager?.location?.coordinate.latitude else { return }
        guard let lng = locationManager?.location?.coordinate.longitude else { return }
        camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
        mapView?.camera = camera
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        mapView?.setMinZoom(8, maxZoom: 20)
        getLocationDetails(latitude: lat, longitude: lng, bool: true)
    }
    
    private func checkPathExist(points: String, dict: [String: String]) {
        if let polyline = polyline {
            polyline.map = nil
        }
        if points.isEmpty, let pathInformation = pathInformationView {
            self.alert(info: AlertConstants.noPathErrorMessage)
            arkitNavigationButton.isEnabled = false
            activityIndicator.isHidden = true
            animateView(constraintView: pathInformation, constraintLayout: pathInformationConstraint, height: UiViewDimension.pathInfoHeight)
        } else {
            displayPathOnMap(points: points, dict: dict)
        }
    }
    
    private func displayPathOnMap(points: String, dict: [String: String]) {
        let path = GMSPath(fromEncodedPath: points)
        polyline = GMSPolyline(path: path)
        polyline?.strokeWidth = 3.0
        polyline?.strokeColor = UIColor.red
        polyline?.map = mapView
        arkitNavigationButton.isEnabled = true
        displayPathInformation(dict: dict)
        let sourceCordinate = CLLocationCoordinate2D(latitude: source.lat, longitude: source.lng)
        let destinationCordinate = CLLocationCoordinate2D(latitude: destination.lat, longitude: destination.lng)
        let bounds = GMSCoordinateBounds(coordinate: sourceCordinate, coordinate: destinationCordinate)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100, 10, 10, 10))
        if let mapView = mapView {
            mapView.animate(with: update)
        }
        activityIndicator.isHidden = true
    }
    
    // MARK: - tableView method
    private func tableRowSelected (arrayDetails: GMSAutocompletePrediction) {
        destinationTextField.text = arrayDetails.attributedPrimaryText.string
        if let placeId = arrayDetails.placeID {
            self.getPlaceCordinateDetails(name: arrayDetails.attributedPrimaryText.string, address: arrayDetails.attributedFullText.string, placeId: placeId)
        }
    }
    
    // MARK: - Setting up UI Components
    private func displayTableorMap(visibleTable: Bool, VisibleMap: Bool) {
        tableView.isHidden = visibleTable
        mapView?.isHidden = VisibleMap
    }
    
    private func setSourceTextField(name: String) {
        sourceTextField.text = name
        sourceTextField.isUserInteractionEnabled = false
    }
    
    private func setUpSearchBar(place: GMSPlace) {
        searchController?.isActive = false
        camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15)
        mapView?.camera = camera
        guard let address = place.formattedAddress else { return }
        if let mapView = self.mapView {
            destinationMarker = setMarker(lat: place.coordinate.latitude, long: place.coordinate.longitude, name: place.name, address: address, mapView: mapView)
            destinationMarker.map = mapView
        }
        displayLocationInformation(name: place.name, address: address, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
    }
    
    private func setModeButton(driveImage: String, driveColor: UIColor, walkImage: String, walkColor: UIColor) {
        driveModeButton.setImage(UIImage(named: "\(driveImage)"), for: .normal)
        driveModeButton.setTitleColor(driveColor, for: .normal)
        walkModeButton.setImage(UIImage(named: "\(walkImage)"), for: .normal)
        walkModeButton.setTitleColor(walkColor, for: .normal)
    }
    
    private func setMarker(lat: Double, long: Double, name: String, address: String, mapView: GMSMapView) -> GMSMarker {
        destinationMarker.map = nil
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = name
        marker.snippet = address
        return marker
    }
    
    private func displayPathInformation(dict: [String: String]) {
        mapView?.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        if pathInformationView == nil {
            if let view = Bundle.main.loadNibNamed(String(describing: PathInformationWindow.self), owner: nil, options: nil)?.first as? PathInformationWindow {
                pathInformationView = view
                containerView.addSubview(view)
                containerView.bringSubview(toFront: view)
            }
        }
        if let pathInformationView = pathInformationView {
            pathInformationConstraint.setContraint(containerView: containerView, height: UiViewDimension.pathInfoHeight, constraintView: pathInformationView, bottom: 0)
            containerView.layoutIfNeeded()
            pathInformationView.distanceLabel.text = dict[ApiResponseConstant.distance]
            pathInformationView.durationLabel.text = dict[ApiResponseConstant.duration]
        }
   }
    
    private func displayLocationInformation(name: String, address: String, lat: Double, lng: Double) {
        if locationinformationView == nil {
            if  let view = Bundle.main.loadNibNamed(String(describing: InformationWindow.self), owner: nil, options: nil)?.first as? InformationWindow {
                locationinformationView = view
                locationinformationView?.directionButton.addTarget(self, action: #selector(MapViewController.directionButtonClicked), for: .touchUpInside)
                locationinformationView?.closeButton.addTarget(self, action: #selector(MapViewController.closeLocationInformationView), for: .touchUpInside)
                containerView.addSubview(view)
                containerView.bringSubview(toFront: view)
            }
        }
        if let locationinformationView = locationinformationView {
         locationInformationConstraint.setContraint(containerView: containerView, height: UiViewDimension.locationInfoHeight, constraintView: locationinformationView, bottom: 0)
         containerView.layoutIfNeeded()
         locationinformationView.nameLabel.text = name
         locationinformationView.placeLabel.text = address
        }
        destination = LocationDetails(lat: lat, lng: lng, name: name)
        searchController?.searchBar.text = name
    }
    
    // MARK: - Google api call methods
    private func displayLocationOnTable(loc: String) {
        GMSPlacesClient.shared().autocompleteQuery(loc, bounds: nil, filter: nil, callback: { [weak self] result, error in
            guard let self = self else { return }
            if error == nil, let result = result {
                self.arrayAddress = result
                self.displayTableorMap(visibleTable: false, VisibleMap: true)
                self.tableView.reloadData()
            } else {
                self.displayTableorMap(visibleTable: true, VisibleMap: false)
            }
        })
    }
    
    private func displayNearbyLocationIcon(_ placeDetailArray: ([Place])) {
        for placeObj in placeDetailArray {
            if let name = placeObj.name, let address = placeObj.vicinity, let mapView = self.mapView {
                let marker = self.setMarker(lat: placeObj.latitude, long: placeObj.longitude, name: name, address: address, mapView: mapView)
                marker.icon = UIImage(named: "nearByPlace")
                marker.map = self.mapView
                guard let icon = placeObj.icon else { return }
                LocationIcon.getImagefromUrl(url: icon, success: { image in
                    marker.icon = image
                    marker.map = mapView
                }, failure: { alertString in
                    self.alert(info: alertString)
                })
            }
        }
    }
    
    private func getdirection() {
        self.activityIndicator.isHidden = false
        arkitNavigationButton.isEnabled = false
        googleApi.getRoute(source: source, destination: destination, mode: mode, success: { [weak self] points, steps, dict in
            guard let self = self else { return }
            self.checkPathExist(points: points, dict: dict)
            self.steps.removeAll()
            self.steps = steps
            }, failure: { alertString in
                self.alert(info: alertString)
        })
    }
    
    private func getNearbyLocation() {
        googleApi.getNearbyplace(latitude: self.source.lat, longitude: self.source.lng, radius: Float(self.radius), success: { [weak self] placeDict -> Void in
            guard let self = self else { return }
            self.coreDataObject.insert(nearbyPlaceDict: placeDict, success: { [weak self] placeDetailArray in
                guard let self = self else { return }
                self.mapView?.clear()
                self.displayNearbyLocationIcon(placeDetailArray)
                self.activityIndicator.isHidden = true
                }, failure: { alertString in
                    self.alert(info: alertString)
            })
            }, failure: { alertString in
                self.alert(info: alertString)
        })
    }

    private func getPlaceCordinateDetails(name: String, address: String, placeId: String) {
        googleApi.getplaceCordinate(placeId: placeId, success: {[weak self] placeCordinate in
            guard let self = self else { return }
            if let mapView = self.mapView {
                 self.destinationMarker = self.setMarker(lat: placeCordinate.latitude, long: placeCordinate.longitude, name: name, address: address, mapView: mapView)
                self.destinationMarker.map = self.mapView
                }
                self.destination = LocationDetails(lat: placeCordinate.latitude, lng: placeCordinate.longitude, name: name)
                self.getdirection()
            }, failure: { alertString  in
                self.alert(info: alertString)
        })
    }
    
    private func getLocationDetails(latitude: Double, longitude: Double, bool: Bool) {
        googleApi.getAddress(latitude: latitude, longitude: longitude, success: { [weak self] address in
            guard let self = self else { return }
            guard let name = address[ApiResponseConstant.name] as? String else { return }
            guard  let address = address[ApiResponseConstant.locationaddress] as? String  else { return }
            if bool {
                self.source = LocationDetails(lat: latitude, lng: longitude, name: name)
                    self.setSourceTextField(name: self.source.name)
                    if let newRadius = (self.mapView?.getRadius()) {
                        self.radius = newRadius
                    }
                self.getNearbyLocation()
            } else {
                if let mapView = self.mapView {
                    self.destinationMarker = self.setMarker(lat: latitude, long: longitude, name: name, address: address, mapView: mapView)
                    self.destinationMarker.map = mapView
                    self.displayLocationInformation(name: name, address: address, lat: latitude, lng: longitude)
                }
            }
            }, failure: { alertString in
                self.alert(info: alertString)
        })
    }
}

// MARK: - MapView Delegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        getLocationDetails(latitude: coordinate.latitude, longitude: coordinate.longitude, bool: false)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let title = marker.title else { return false }
        guard let address = marker.snippet else { return false }
        displayLocationInformation(name: title, address: address, lat: marker.position.latitude, lng: marker.position.longitude)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            if mapView.camera.zoom < 15 {
                if let newRadius = self.mapView?.getRadius(), newRadius < 50000 {
                    self.radius = newRadius
                    self.getNearbyLocation()
         }
      }
    }
}
}

// MARK: - Google AutoCompolete delegate
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        setUpSearchBar(place: place)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        alert(info: AlertConstants.locationDetailErrorMessage)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - CoreLocation delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getCurrentLocation()
    }
}

// MARK: - TextField delegate
extension MapViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        guard  let loc = nsString?.replacingCharacters(in: range, with: string) else { return false }
        if loc.isEmpty {
            self.arrayAddress = [GMSAutocompletePrediction] ()
        } else {
            displayLocationOnTable(loc: loc)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinationTextField.endEditing(true)
        displayTableorMap(visibleTable: true, VisibleMap: false)
        return false
    }
}

// MARK: - TableView delegate
extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAddress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlaceTableViewCell {
            cell.result = arrayAddress[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        tableRowSelected(arrayDetails: arrayAddress[indexPath.row])
        displayTableorMap(visibleTable: true, VisibleMap: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UiViewDimension.tableHeight
    }
}

// MARK: - searchBar delegate
extension MapViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        locationinformationView?.removeFromSuperview()
    }
}
