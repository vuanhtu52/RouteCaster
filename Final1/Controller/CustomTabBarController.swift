//
//  CustomTabBarController.swift
//  Final1
//
//  Created by Tu Vu on 5/13/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        fetchMess()
        
    }
    
    var numOfMess = UInt()
    func fetchMess() {
        if let currentUser = Auth.auth().currentUser {
            FIRDatabaseReference.sentMess(uid: currentUser.uid).reference().observe(.value) { (snapshot) in
                self.numOfMess = 0
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let value = child.value as? String ?? ""
                    if value == "unread" {
                        self.numOfMess = self.numOfMess + 1
                    }
                }
                DispatchQueue.main.async {
                    if self.numOfMess == 0 {
                        self.tabBar.items?[2].badgeValue = nil
                    }
                    else {
                        self.tabBar.items?[2].badgeValue = String(self.numOfMess)
                    }
                }
                
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == self.tabBar.items?[2] {
            print("TABBARR HIHI")
            if let currentUser = Auth.auth().currentUser {
                let ref = FIRDatabaseReference.sentMess(uid: currentUser.uid).reference()
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        ref.child(child.key).setValue("read")
                    }
                }
            }
        }
    }
}
