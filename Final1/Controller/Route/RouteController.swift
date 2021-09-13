//
//  RouteController.swift
//  Final1
//
//  Created by Sung Jin, Kim  on 5/5/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

enum Location {
    case startLocation
    case destinationLocation
}

class RouteController: UIViewController, GMSMapViewDelegate {
    
    var zoomLevel: Float = 16.0
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var destination:GMSPlace!
    var currentLocation:CLLocation!
    var getFriends = FriendManagement()
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()

        //Your map initiation code
        self.mapView.delegate = self
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.isMyLocationEnabled = true
        
        // default text of textfield
        startLocation.text = "Your Location"
        destinationLocation.text = destination.name
    
        createMarker(titleMarker: "Ending point", latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        
        // default polyline dependent on the user's current location and searched destination
        locationStart = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        locationEnd = CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        drawPath(startLocation: locationStart, endLocation: locationEnd)
    }
    
    func createMarker(titleMarker: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.map = mapView
    }
    
    @IBAction func startPoint(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: false, completion: nil)
        
    }
    
    @IBAction func endPoint(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: false, completion: nil)
        
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCuYF0HSL_xOTWM6Wk_4TwFN3eSdzIghck"
        
        Alamofire.request(url).responseJSON { response in
            
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // Measure the time and distance and display them
            let time = json["routes"][0]["legs"][0]["duration"]["text"].stringValue as String
            let distance = json["routes"][0]["legs"][0]["distance"]["text"].stringValue as String
            self.time.text = time
            
            let onlyDis = distance.filter("01234567890.".contains)
            self.getFriends.getRouteSetting{(completion) in
                if completion {
                    // using this to get setting
                    let unit = self.getFriends.unit
                    print(onlyDis)
                    if(unit != "kilometer"){
                        if distance.range(of: "m") != nil{
                            let calculate = Double(onlyDis)! * 0.000621371
                            let mile = String(format: "%.2f", calculate)
                            self.distance.text = "\(mile) mi"
                            
                        }else if distance.range(of: "km") != nil{
                            let calculate = Double(onlyDis)! * 0.621371
                            let mile = String(format: "%.2f", calculate)
                            self.distance.text = "\(mile) mi"
                        }
                    }else{
                        self.distance.text = distance
                    }
                }
            }
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.mapView
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "navigation"){
            if let navigation = segue.destination as? NavigationController{
                navigation.locationStart = locationStart
                navigation.locationEnd = locationEnd
                navigation.hidesBottomBarWhenPushed = true
            }
        }
        
        if(segue.identifier == "backToHome"){
            if let home = segue.destination as? HomeViewController{
                home.navigationController?.isNavigationBarHidden = false
            }
        }
    }
    
    @IBAction func showDirections(_ sender: Any) {
        performSegue(withIdentifier: "navigation", sender: nil)
    }
}

extension RouteController:GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Change map location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: zoomLevel
        )

        if locationSelected == .startLocation{
            startLocation.text = place.name
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location Start", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }else{
            destinationLocation.text = place.name
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(titleMarker: "Location End", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        if locationSelected == .destinationLocation{
            locationStart = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            createMarker(titleMarker: "Location End", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }else {
            createMarker(titleMarker: "Ending point", latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        }
        
        self.drawPath(startLocation: locationStart, endLocation: locationEnd)
        self.mapView.camera = camera
        self.dismiss(animated: false, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: false, completion: nil)
    }
}

extension RouteController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        self.mapView?.animate(to: camera)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}


