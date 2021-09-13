//
//  FriendManagement.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/11/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import Foundation
import Firebase

class FriendManagement {
    var users = [User]()
    var friendIdList = [String]()
    var friends = [User]()
    var displayWith = String()
    var unit = String()
    var friendDisplayType = [FriendDisplayType]()
    
    func getRouteSetting (completion: @escaping (Bool) -> Void) {
        print("in route setting")
        if let currentUser = Auth.auth().currentUser {
            let refSetting = FIRDatabaseReference.setting(uid: currentUser.uid).reference()
            refSetting.observe(.value) { (snapshot) in
                let dictionary = snapshot.value as? NSDictionary
                // Get display and unit value
                self.displayWith = dictionary?["display"] as? String ?? ""
                print(self.displayWith)
                self.unit = dictionary?["unit"] as? String ?? ""
                
                // Get each route setting
                if dictionary?["route"] != nil {
                let value = dictionary?["route"] as! [String: AnyObject]
                for child in value {
                    let temp = FriendDisplayType()
                    temp.friendId = child.key
                    temp.color = child.value["color"] as! String
                    let allowed = child.value["allowed"] as! String
                    let displayOnMap = child.value["displayOnMap"] as! String
                    if allowed == "yes" && displayOnMap == "yes" {
                        temp.status = true
                    } else {
                        temp.status = false
                    }
                    self.friendDisplayType.append(temp)

                    }
                    
                }
                completion(true)
            }
        }
    }
    
    
    // Fetch all users data from database except for current user and save it into variable
    func fetchUser (completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.root.reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let dictionary = child.value as? [String: AnyObject] {
                        let user = User(dictionary: dictionary)
                    
                        user.setUid(uid: child.key)
                        if (currentUser.uid != user.uid) {
                            self.users.append(user)
                        }
                    }
                }
                completion(true)
            }, withCancel: nil) 
        }
    }
    
    // Get all current user's friends id list
    func getFriendList(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.root.reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let dictionary = child.value as? [String: AnyObject] {
                        let user = User(dictionary: dictionary)
                        
                        user.setUid(uid: child.key)
                        if (currentUser.uid != user.uid) {
                            self.users.append(user)
                        }
                    }
                }
                
            }, withCancel: nil)
                FIRDatabaseReference.friendList(uid: currentUser.uid).reference().observeSingleEvent(of: .value) { (snapshot) in
                    self.friendIdList = []
                    self.friends = []
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        let value = child.value as? String ?? ""
                        if value == "friend" {
                            
                            self.friendIdList.append(child.key)
                        }
                    }
                    for user in self.users {
                        for friendid in self.friendIdList {
                            if user.uid! == friendid {
                                self.friends.append(user)
                                continue
                            }
                        }
                    }
                    completion(true)
                }
        }
    }
}


class FriendDisplayType {
    var friendId = String()
    var color = String()
    var status = true
    
    init() {}
}
