//
//  BaseSearchTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/4/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class BaseSearchTableViewController: UITableViewController, UISearchResultsUpdating {

    // Variable
    var users = [User]()
    var filterUsers = [User]()
    let cellId = "cellId"
    var friendIdList = [String]()
    var friends = [User]()
    
    var searchController = UISearchController()
    var resultController = UITableViewController()
    
    // Update table view based on the search content
    func updateSearchResults(for searchController: UISearchController) {
        self.filterUsers = users.filter({ (user: User) -> Bool in
            let searchContent = searchController.searchBar.text!.lowercased()
            let name = user.displayedName!.lowercased()
            let email = user.email!.lowercased()
            if name.contains(searchContent) || email.contains(searchContent)
            {
                return true
            }
            else
            {
                return false
            }

        })

        self.resultController.tableView.reloadData()
    }
    
    // Fetch all users data from database except for current user and save it into variable
    func fetchUser () {
        print("in fetch")
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.root.reference().child("users").observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.setUid(uid: snapshot.key)
                    if (currentUser.uid != user.uid) {
                        self.users.append(user)
                        
                    }
                    
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }, withCancel: nil)
        }
    }
    
    // Get all current user's friends id list
    func getFriendList() {
        print("in list")
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            print(currentUser.uid)
            saveFriendList(currentUser.uid)
        }
    }
    
    func saveFriendList(_ uid: String) {
        FIRDatabaseReference.friendList(uid: uid).reference().observe(.value) { (snapshot) in
            print(snapshot)
            self.friendIdList = []
            self.friends = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as? String ?? ""
                if value == "friend" {
                    print(child.key)
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
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                print(self.friends.count)
            })
        }
    }
    
    // Dismiss screen
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}


