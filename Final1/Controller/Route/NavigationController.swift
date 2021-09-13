//
//  navigationController.swift
//  Final1
//
//  Created by Sung Jin, Kim  on 5/8/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//



import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import Firebase
import GeoFire

class NavigationController: UIViewController {
    var getFriends = FriendManagement()
    var locationManager = CLLocationManager()
    var location:CLLocation!
    var zoomLevel: Float = 18.0
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var path = GMSPath()
    var encodedPath = String()
    var traveledDistance: Double = 0
    var startLocation: CLLocation!
    var lastLocation:CLLocation!
    var sharedObjects = [Any]()
    var actualDistance = ""
    var countingTimer: Timer?
    var tickCount = 0
    let tickRate = 1.0
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "RouteCaster"
        
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 1
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        drawPath(startLocation: locationStart, endLocation: locationEnd)
        createMarker(latitude: locationEnd.coordinate.latitude, longitude: locationEnd.coordinate.longitude)
        startTimer()
    }
  
    
    func startTimer() {
        // Create and configure the timer for 1.0 second ticks.
        countingTimer = Timer.scheduledTimer(timeInterval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: "Tick: ", repeats: true)
        // Make the timer efficient.
        countingTimer?.tolerance = 0.15
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
    }
    
    func stopTimer() {
        // Destroy timer.
        countingTimer?.invalidate()
    }
    
    @objc func onTimerTick(timer: Timer) -> Void {
        
        // Get custom data sent from timer.
        let preface = timer.userInfo as? String
        
        tickCount += 1
    }
    
    //Upload startring point and end point of coordinates of route
    func uploadRoute() {
        if Auth.auth().currentUser != nil {
            let ref = FIRDatabaseReference.users(uid: Auth.auth().currentUser!.uid).reference()
            let geofire = GeoFire(firebaseRef: ref)
            geofire.setLocation(locationStart, forKey: "RouteStart")
            geofire.setLocation(locationEnd, forKey: "RouteEnd")
        }
    }
    
    func clearRoute() {
        if Auth.auth().currentUser != nil {
            let ref = FIRDatabaseReference.users(uid: Auth.auth().currentUser!.uid).reference()
            ref.child("RouteStart").removeValue()
            ref.child("RouteEnd").removeValue()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backToHome"){
            if let home = segue.destination as? HomeViewController{
                stopTimer()
                clearRoute()
                home.navigationController?.isNavigationBarHidden = false
            }
        }
    }
    
    func createMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.map = mapView
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        uploadRoute()
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
                self.path = GMSPath.init(fromEncodedPath: points!)!
                let polyline = GMSPolyline.init(path: self.path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.mapView
                self.encodedPath = self.path.encodedPath()
            }
        }
    }
    
    
    func arrived(startLocation: CLLocation, endLocation: CLLocation){
        // setting up actual time and distance
        let totalDuration = String(tickCount)
        let durationMinutes = String(tickCount/60)
        let durationSeconds = String(tickCount%60)
        let averageSpeed: Double = ((traveledDistance/Double(tickCount)*3.6))
        let avgSpeed = String(format: "%.2f", averageSpeed)
        
        // setting up timestamp for route ID for record-keeping
        // Create date
        let date = Date()
        // Create calendar object
        let calendar = Calendar.current
        // Get components using current Local & Timezone
        print(calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date))
        // Get All components from date
        let components = calendar.dateComponents([.hour, .year, .minute], from: date)
        print("All Components : \(components)")
        // Get Individual components from date
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let routeID = String("\(year)-\(month)-\(day)-\(hour)-\(minutes)-\(seconds)")
        print(routeID)
        
        clearRoute()
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        let encoPath = encodedPath
        
        // Get photo of completed route
        let staticRequest = "https://maps.googleapis.com/maps/api/staticmap?size=500x500&scale=2&maptype=roadmap&markers=label:1|\(origin)&markers=label:2|\(destination)&path=weight:5|color:blue|enc:\(encoPath)&key=AIzaSyCuYF0HSL_xOTWM6Wk_4TwFN3eSdzIghck"
        
        // Convert staticRequest to URL
        let staticString = staticRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let staticURL = URL(string: staticString)!
        
        // Convert URL to Data
        let staticData = try? Data(contentsOf: staticURL)
        
        // Convert Data to UIImage and upload this iamge to Firebase Storage
        
        // Share object
        let shareMessage = "Check out this route I just finished!\n\nActual distance: \(actualDistance)\n\nActual time: \(totalDuration)\n\nRoute snapshot: \(staticURL)"
        sharedObjects = shareMessage.split(separator: "\n") as [Any]
        
        let alert = UIAlertController(title: "You have arrived", message: "Actual distance: \(actualDistance) meters\nActual time: \(durationMinutes) minutes \(durationSeconds) seconds\nAverage speed: \(avgSpeed) km/h", preferredStyle: .alert)
        var imageURL = ""
        let save = UIAlertAction(title: "Save", style: .default, handler: {(action) -> Void in
            if let staticMap = UIImage(data: staticData!) {
                let firImage = ProfileImage(image: staticMap)
                if let imageData = staticMap.pngData(), let currentUser = Auth.auth().currentUser {
                    // 1. get the reference
                    firImage.ref = FIRStorageReference.staticMap(uid: currentUser.uid).referene().child("\(routeID).png")
                    
                    // 2. save that to the reference
                    firImage.ref.putData(imageData, metadata: nil, completion: { (_, error) in
                        if let error = error {
                            print(error)
                            return
                        }else{
                            firImage.ref.downloadURL(completion: { (url, err) in
                                if let err = err {
                                    print(err)
                                    return
                                }
                                
                                guard let url = url else { return }
                                imageURL = url.absoluteString
                                
                                // save route data to firebase
                                let ref = FIRDatabaseReference.route(uid: currentUser.uid).reference().child(routeID)
                                let value = [
                                    "imageURL": imageURL,
                                    "duration": "\(totalDuration)",
                                    "avgSpeed": "\(avgSpeed)",
                                    "date": "\(day):\(month):\(year)",
                                    "time": "\(hour):\(minutes):\(seconds)",
                                    "startpoint": "\(startLocation)",
                                    "endpoint": "\(endLocation)"
                                ]
                                ref.setValue(value)
                            })
                        }
                    })
                }
            }
            
            let saving = UIAlertController(title: "Route saved", message: "", preferredStyle: .alert)
            print(self.sharedObjects)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {(action)->Void in
                self.performSegue(withIdentifier: "backToHome", sender: nil)
            })
            saving.addAction(ok)
            self.present(saving,animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Forget", style: .cancel, handler: {(action) -> Void in
            self.performSegue(withIdentifier: "backToHome", sender: nil)
        })
        
        let saveAndShare = UIAlertAction(title: "Save & Share", style: .default, handler: {(action) -> Void in
            if let staticMap = UIImage(data: staticData!) {
                let firImage = ProfileImage(image: staticMap)
                if let imageData = staticMap.pngData(), let currentUser = Auth.auth().currentUser {
                    // 1. get the reference
                    firImage.ref = FIRStorageReference.staticMap(uid: currentUser.uid).referene().child("\(routeID).png")
                    
                    // 2. save that to the reference
                    firImage.ref.putData(imageData, metadata: nil, completion: { (_, error) in
                        if let error = error {
                            print(error)
                            return
                        }else{
                            firImage.ref.downloadURL(completion: { (url, err) in
                                if let err = err {
                                    print(err)
                                    return
                                }
                                
                                guard let url = url else { return }
                                imageURL = url.absoluteString
                                
                                // save route data to firebase
                                let ref = FIRDatabaseReference.route(uid: currentUser.uid).reference().child(routeID)
                                let value = [
                                    "imageURL": imageURL,
                                    "duration": "\(totalDuration)",
                                    "avgSpeed": "\(avgSpeed)",
                                    "date": "\(day):\(month):\(year)",
                                    "time": "\(hour):\(minutes):\(seconds)",
                                    "startpoint": "\(startLocation)",
                                    "endpoint": "\(endLocation)"
                                ]
                                ref.setValue(value)
                            })
                        }
                    })
                }
            }
            
            let share = UIAlertController(title: "Where would you like to share?", message: "", preferredStyle: .alert)
            
            let friend = UIAlertAction(title: "Friends in app", style: .default, handler: {(action) -> Void in
                //self.performSegue(withIdentifier: "appFriend", sender: nil)
                let chooseFriendToShare = ChooseShareInApp()
                chooseFriendToShare.sharedObjects = self.sharedObjects
                
                let navController = UINavigationController(rootViewController: chooseFriendToShare)
                
                self.present(navController, animated: true, completion: nil)
            })
            
            let media = UIAlertAction(title: "Other social media", style: .default, handler: {(action) -> Void in
                
                let ac = UIActivityViewController(activityItems: self.sharedObjects, applicationActivities: nil)
                self.present(ac, animated: true)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in
                self.performSegue(withIdentifier: "backToHome", sender: nil)
            })
            
            cancel.setValue(UIColor.red, forKey: "titleTextColor")
            share.addAction(friend)
            share.addAction(media)
            share.addAction(cancel)
            self.present(share, animated: true)
        })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(save)
        alert.addAction(saveAndShare)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

extension NavigationController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            actualDistance = String(format: "%.2f", traveledDistance)
        }
        lastLocation = locations.last
        
        let currentLocation = locations.last!
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
        
        
        //out-of-route check
        if GMSGeometryIsLocationOnPathTolerance(currentLocation.coordinate, path, true, 50.0) == false{
            stopTimer()
            let updateRoute = UIAlertController(title: "You are out of your route", message: "We wil suggest you a new route", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
                self.mapView.clear()
                self.createMarker(latitude: self.locationEnd.coordinate.latitude, longitude: self.locationEnd.coordinate.longitude)
                self.drawPath(startLocation: currentLocation, endLocation: self.locationEnd)
                
            })
            updateRoute.addAction(ok)
            self.present(updateRoute,animated: true)
            clearRoute()
            startTimer()
        }
        // arrival check
        if GMSGeometryDistance(currentLocation.coordinate,locationEnd.coordinate) < 20.0{
            stopTimer()
            mapView.clear()
            arrived(startLocation: locationStart, endLocation: locationEnd)
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

