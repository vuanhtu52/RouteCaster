//
//  locationInfoController.swift
//  Final1
//
//  Created by Sung Jin, Kim  on 5/5/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

class LocationInfoController: UIViewController {
    
    let zoomLevel: Float = 16.0
    var searchbarText:String = ""
    var place:GMSPlace!
    var currentLocation:CLLocation! // to pass the current location data
    var getFriends = FriendManagement()
    var startPoint = CLLocation()
    var endPoint = CLLocation()
    
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "RouteCaster"
        locationName.text = place.name
        
        let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: zoomLevel)
        mapview.camera = camera
        showMarker(position: camera.target)
        
        startPoint = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        endPoint = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        distances(startpoint: startPoint, endpoint: endPoint)
        
    }
    
    @IBAction func showDirections(_ sender: Any) {
        performSegue(withIdentifier: "showRoute", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showRoute"){
            if let destination = segue.destination as? RouteController{
                destination.destination = place
                destination.currentLocation = currentLocation
            }
        }
    }
    
    func showMarker(position: CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = position
        marker.title = "Hello"
        marker.snippet = "im'jin"
        marker.map = mapview
    }
    
    func distances(startpoint:CLLocation, endpoint:CLLocation){
        let start = "\(startpoint.coordinate.latitude),\(startpoint.coordinate.longitude)"
        let end = "\(endpoint.coordinate.latitude),\(endpoint.coordinate.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start)&destination=\(end)&mode=driving&key=AIzaSyCuYF0HSL_xOTWM6Wk_4TwFN3eSdzIghck"
        
        Alamofire.request(urlString).responseJSON { response in
            
            let json = try! JSON(data: response.data!)
            
            // Measure the distance
            let dis = json["routes"][0]["legs"][0]["distance"]["text"].stringValue as String
            let onlyDis = dis.filter("01234567890.".contains)
        
            self.getFriends.getRouteSetting{(completion) in
                if completion {
                    // using this to get setting
                    let unit = self.getFriends.unit
                    print(onlyDis)
                    if(unit != "kilometer"){
                        if dis.range(of: "m") != nil{
                            let calculate = Double(onlyDis)! * 0.000621371
                            let mile = String(format: "%.2f", calculate)
                            self.distanceLabel.text = "\(mile) mi"
                            
                        }else if dis.range(of: "km") != nil{
                            let calculate = Double(onlyDis)! * 0.621371
                            let mile = String(format: "%.2f", calculate)
                            self.distanceLabel.text = "\(mile) mi"
                        }
                    }else{
                        self.distanceLabel.text = dis
                    }
                }
            }
        }
    }
}
