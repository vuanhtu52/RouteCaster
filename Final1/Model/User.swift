//
//  User.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/23/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GeoFire

class User : NSObject {
    var displayedName: String?
    var email: String?
    var uid: String?
    var profileImage: UIImage?
    var profileImageURL: String?
    var username: String?
    var baseSearch = BaseSearchTableViewController()
    var userLatitude: String?
    var userLongtitude: String?
    var userRouteURL: String?
    var locationManager = CLLocation()
    var currentLocation:CLLocation!
    
    
    override init(){}
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String
        self.displayedName = dictionary["displayedName"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageURL = dictionary["profileImageURL"] as? String
        self.userLatitude = dictionary["userLatitude"] as? String
        self.userLongtitude = dictionary["userLongtitude"] as? String
        self.userRouteURL = dictionary["userRouteURL"] as? String
    }
    
    func setUid (uid: String) {
        self.uid = uid
    }
    
    init(username: String ,uid: String, displayedName: String, email: String, profileImage: UIImage, userLongtitude: String, userLatitude: String, userRouteURL: String) {
        self.uid = uid
        self.username = username
        self.displayedName = displayedName
        self.email = email
        self.profileImage = profileImage
        self.userLongtitude = userLongtitude
        self.userLatitude = userLatitude
        self.userRouteURL = userRouteURL
    }
    
    // Save user information
    func save() {
        // Reference to the database
        let ref = FIRDatabaseReference.users(uid: uid!).reference()
        
        // Set value to the reference
        ref.setValue(toDictionary())
    }
    
    
    func toDictionary() -> [String: Any] {
        print("to dic")
        return [
            "username": username!,
            "email": email!,
            "displayedName": displayedName!,
            "profileImageURL": profileImageURL!
        ]
    }
    
//    // Undo/Cancel request that has been made
//    func undoRequest() {
//        let alert = UIAlertController(title: "Cancel Request?", message: nil, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
//            self.removeFriend()
//        }
//        alert.addAction(okAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        alert.addAction(cancelAction)
//        baseSearch.present(alert, animated: true, completion: nil)
//    }
    
    // Discard all relationships (unfriend/ decline friend request/ cancel request) between two users
    func removeFriend() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
            ref.child(uid!).removeValue()
            let ref2 = FIRDatabaseReference.friendList(uid: uid!).reference()
            ref2.child(currentUser.uid).removeValue()
            
            let refSetting = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(uid!)
            refSetting.removeValue()
            let refSetting2 = FIRDatabaseReference.setting(uid:uid!).reference().child("route").child(currentUser.uid)
            refSetting2.removeValue()
            
            // Clear notification when user cancel sent request
            let refRequest = FIRDatabaseReference.sentRequests(uid: uid!).reference().child(currentUser.uid)
            refRequest.removeValue()
        }
    }
    
    // Send request asking for add friend
    func addFriend() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            // Update friend status value for both users
            let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
            let dic : [String: String] = ["\(String(describing: uid!))" : "sent"]
            ref.updateChildValues(dic)
            let ref2 = FIRDatabaseReference.friendList(uid: uid!).reference()
            let dic2 : [String: String] = ["\(currentUser.uid)" : "received"]
            ref2.updateChildValues(dic2)
            
            // Add sent request to notification
            let refRequest = FIRDatabaseReference.sentRequests(uid: uid!).reference().child(currentUser.uid)
            refRequest.setValue("unread")
        }
    }
    
    // Request Respond: Accept or Decline
    func respondRequest () {
        let alert = UIAlertController(title: nil, message: "Do you want to add this person?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Accept", style: .default) { (okAction) in
            self.acceptRequest()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Decline", style: .default) {
            (cancelAction) in
            self.removeFriend()
        }
        alert.addAction(cancelAction)
        baseSearch.present(alert, animated: true, completion: nil)
    }
    
    // Accept request from others
    func acceptRequest() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            // Update friend status to FRIEND
            let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
            let dic : [String: String] = ["\(String(describing: uid!))" : "friend"]
            ref.updateChildValues(dic)
            
            let ref2 = FIRDatabaseReference.friendList(uid: uid!).reference()
            let dic2 : [String: String] = ["\(currentUser.uid)" : "friend"]
            ref2.updateChildValues(dic2)
            
            //
            
            // Add friend setting default value
            let refSetting = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(uid!)
            let refSetting2 = FIRDatabaseReference.setting(uid: uid!).reference().child("route").child(currentUser.uid)
            let settingValue = [
                "displayOnMap" : "yes",
                "color": "blue",
                "allowed": "yes"
            ]
            refSetting.updateChildValues(settingValue)
            refSetting2.updateChildValues(settingValue)
            
            // Clear notification
            let refRequest = FIRDatabaseReference.sentRequests(uid: currentUser.uid).reference().child(uid!)
            refRequest.removeValue()
        }
    }
    
    func viewProfile() {
        baseSearch.performSegue(withIdentifier: "showProfile", sender: nil)
    }
}
