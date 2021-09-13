//
//  FriendsRouteInforController.swift
//  Final1
//
//  Created by Sung Jin, Kim  on 5/15/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire
import GeoFire
import Firebase

class FriendsRouteInfoController: UIViewController {

    var place:GMSPlace!
    var startPoint = CLLocation()
    var endPoint = CLLocation()
    var getFriends = FriendManagement()
    var userID:String = ""
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var distance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsRoute()
        time.text = ""
        distance.text = ""
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
                    var routeColor:UIColor = .blue
                    var color:String = ""
                    let unit = self.getFriends.unit
                    
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
                            polyline.map = self.mapview
                        }
                    }
                }
            }
        }
    }
    
    func friendMarker(position: CLLocationCoordinate2D,markerIcon:UIImage){
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapview
        marker.icon = markerIcon
        marker.setIconSize(scaledToSize: .init(width: 40, height: 40))
    }
    
    func createMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.map = mapview
    }
    
    func friendsRoute(){
        getFriends.getFriendList { (completion) in
            if completion {
                //for id in self.getFriends.friendIdList{
                    let friendRef = FIRDatabaseReference.users(uid: self.userID).reference()
                    let friendGeofire = GeoFire(firebaseRef: friendRef)
                    let ref = FIRDatabaseReference.root.reference().child("users")
                    
                    
                    if (Auth.auth().currentUser != nil){
                        // Get friends current location's coordinate
                        friendGeofire.getLocationForKey("Coordinate", withCallback: {(location, error) in
                            if error != nil{
                                print("Error getting UserLocation from Geofire \(error.debugDescription)")
                            }else {
                                let camera = GMSCameraPosition.camera(withTarget: location!.coordinate, zoom: 16.0)
                                self.mapview.camera = camera
                                
                                // Get friends profile Image
                                ref.child(self.userID).observeSingleEvent(of: .value, with: { (snapshot) in
                                    // retrieve friends' profile image URL's
                                    let value = snapshot.value as? NSDictionary
                                    let profileImageURL = value?["profileImageURL"] as? String ?? ""
                                    let convertURL = URL(string: profileImageURL)!
                                    let data = try? Data(contentsOf: convertURL)
                                    let markerimage = UIImage(data: data!)
                                    self.friendMarker(position: (location?.coordinate)!, markerIcon: markerimage!)
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
