//
//  HomeViewController.swift
//  Final1
//
//  Created by Sung Jin, Kim on 4/23/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import GeoFire
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, UISearchBarDelegate, UINavigationBarDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var zoomLevel: Float = 16.0
    var places:GMSPlace!
    var getFriends = FriendManagement()
    var startPoint = CLLocation()
    var endPoint = CLLocation()
    var profileImage:UIImage!
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black // change color for status bar
        self.title = "RouteCaster"
        self.view.endEditing(true)
        searchbar.delegate = self
        searchbar.placeholder = "search for destination"
        searchbar.backgroundColor = .white
        
        mapView.clear()
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 1
        self.locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        receivedRequest()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "noti"), style: .plain, target: self, action: #selector(handleNoti))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sidebar"), style: .plain, target: self, action: #selector(handleNoti))
    }
    
    var numOfNoti = UInt();
    
    func receivedRequest() {
        if let currentUser = Auth.auth().currentUser {
            let refRequest = FIRDatabaseReference.sentRequests(uid: currentUser.uid).reference()
            refRequest.observe(.value) { (snapshot) in
                self.numOfNoti = snapshot.childrenCount
                if self.numOfNoti != 0 {
                    self.navigationItem.rightBarButtonItem?.addBadge(number: self.numOfNoti)
                }
                else {
                    self.navigationItem.rightBarButtonItem?.removeBadge()
                }
            }
        }
    }
    
    @objc func handleNoti () {
        if let currentUser = Auth.auth().currentUser {
            let refRequest = FIRDatabaseReference.sentRequests(uid: currentUser.uid).reference()
            refRequest.removeValue()
        }
        let noti = NotiTableViewController()
        //editProfile.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(noti, animated: true)
    }
    
    // This function is to come back to homeViewController from anywhere
    @IBAction func unwindToHome (segue: UIStoryboardSegue) {}
    
    func showMarker(position: CLLocationCoordinate2D, markerIcon:UIImage){
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapView
        marker.icon = markerIcon
        marker.setIconSize(scaledToSize: .init(width: 40, height: 40))
    }
    
    // trigger for appearing Google autocomplete table
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(searchbar.selectedScopeButtonIndex == 0){
            let acController = GMSAutocompleteViewController()
            acController.delegate = self
            present(acController, animated: false, completion: nil)
        } else if(searchbar.selectedScopeButtonIndex == 1){
            performSegue(withIdentifier: "friendsInfo", sender: nil)
        }
        searchbar.resignFirstResponder()
    }
    
    // Using this function to pass the data btn HomeView to locationInfo
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = false
        if(segue.identifier == "locationInfo"){
            if let locationInfo = segue.destination as? LocationInfoController{
                locationInfo.searchbarText = searchbar.text!
                locationInfo.mapview = mapView
                locationInfo.place = places
                locationInfo.currentLocation = currentLocation
                locationInfo.hidesBottomBarWhenPushed = true
            }
        }
        if(segue.identifier == "friendsInfo"){
            if let friendInfo = segue.destination as? SearchFriendsController{
                friendInfo.endPoint = endPoint
                friendInfo.startPoint = startPoint
                friendInfo.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchbar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if(selectedScope == 0){
            searchbar.placeholder = "search for destination"
        }else if(selectedScope == 1){
            searchbar.placeholder = "search for friends"
        }
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCuYF0HSL_xOTWM6Wk_4TwFN3eSdzIghck"
        
        Alamofire.request(url).responseJSON { response in
            
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            self.getFriends.getRouteSetting{(completion) in
                if completion {
                    var routeColor:UIColor = .blue
                    var color:String = ""
                    for friend in self.getFriends.friendDisplayType {
                        color = friend.color
                        if color == "purple"{
                            routeColor = .purple
                        }else if color == "green"{
                            routeColor = .green
                        }else if color == "magenta"{
                            routeColor = .magenta
                        }else if color == "blue"{
                            routeColor = .blue
                        }else if color == "yellow"{
                            routeColor = .yellow
                        }else if color == "cyan"{
                            routeColor = .cyan
                        }else if color == "red"{
                            routeColor = .red
                        }
                        // print route using Polyline
                        for route in routes
                        {
                            let routeOverviewPolyline = route["overview_polyline"].dictionary
                            let points = routeOverviewPolyline?["points"]?.stringValue
                            let path = GMSPath.init(fromEncodedPath: points!)!
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 4
                            polyline.strokeColor = routeColor
                            polyline.map = self.mapView
                        }
                    }
                }
            }
        }
    }
    
    func createMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.map = mapView
    }
   
    func friendsRoute(){
        getFriends.getFriendList { (completion) in
            if completion {
                for id in self.getFriends.friendIdList{
                    let friendRef = FIRDatabaseReference.users(uid: id).reference()
                    let friendGeofire = GeoFire(firebaseRef: friendRef)
                    let ref = FIRDatabaseReference.root.reference().child("users")
                    self.getFriends.getRouteSetting{(completion) in
                        if completion {
                            var color:String = ""
                            for friend in self.getFriends.friendDisplayType {
                                color = friend.color
                            }
                            if color == "Purple"{
                                
                            }else if color == "Green"{
                                
                            }else if color == "Magenta"{
                                
                            }else if color == "Blue"{
                                
                            }else if color == "Yellow"{
                                
                            }else if color == "Cyan"{
                                
                            }else if color == "Red"{
                                
                            }
                        }
                    }
                    
                    if (Auth.auth().currentUser != nil){
                        // Get friends current location's coordinate
                        friendGeofire.getLocationForKey("Coordinate", withCallback: {(location, error) in
                            if error != nil{
                                print("Error getting UserLocation from Geofire \(error.debugDescription)")
                            }else {
                                // Get friends profile Image
                                ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                                    // retrieve friends' profile image URL's
                                    let value = snapshot.value as? NSDictionary
                                    let profileImageURL = value?["profileImageURL"] as? String ?? ""
                                    let convertURL = URL(string: profileImageURL)!
                                    let data = try? Data(contentsOf: convertURL)
                                    let markerImage = UIImage(data: data!)
                                    
                                    self.showMarker(position: location!.coordinate, markerIcon: markerImage!)
                                })
                            }
                        })
                        
                        // Get starting point of friend's route
                        friendGeofire.getLocationForKey("RouteStart", withCallback: {(locationStart, error) in
                            if error != nil{
                                print("Error getting UserLocation from Geofire \(error.debugDescription)")
                            }else {
                                if locationStart != nil{
                                    // Get end point of friend's route
                                    friendGeofire.getLocationForKey("RouteEnd", withCallback: {(locationEnd, error) in
                                        if error != nil{
                                            print("Error getting UserLocation from Geofire \(error.debugDescription)")
                                        }else {
                                            if locationEnd != nil{
                                                self.startPoint = locationStart!
                                                self.endPoint = locationEnd!
                                                self.drawPath(startLocation: locationStart!, endLocation: locationEnd!)
                                                self.createMarker(latitude: (locationEnd?.coordinate.latitude)!, longitude: (locationEnd?.coordinate.longitude)!)
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // For one time signin/login
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear of home")
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // User is signed in.
                // ...
                print("in home have users")
            } else {
                print("in home no users")
                // No user is signed in.
                self.performSegue(withIdentifier: "showWelcome", sender: nil)
            }
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocations:CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLocations.coordinate.latitude,
                                              longitude: currentLocations.coordinate.longitude,
                                              zoom: 16.0)
        self.mapView?.animate(to: camera)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        currentLocation = currentLocations
        
        //save user's current location in the firebase
        if Auth.auth().currentUser != nil {
            let ref = FIRDatabaseReference.users(uid: Auth.auth().currentUser!.uid).reference()
            let geofire = GeoFire(firebaseRef: ref)
            geofire.setLocation(currentLocation, forKey: "Coordinate")
        }

        getFriends.getRouteSetting{(completion) in
            if completion{
                var comfirm:Bool = true
                for friend in self.getFriends.friendDisplayType{
                    comfirm = friend.status
                    if comfirm == true{
                        self.friendsRoute()
                    }
                }
            }
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

extension HomeViewController:GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        places = place
        performSegue(withIdentifier: "locationInfo", sender: nil)
        dismiss(animated: true, completion: nil)
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

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
