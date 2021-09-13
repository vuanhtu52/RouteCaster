//
//  PrivacyTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/15/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class PrivacyTableViewController: UITableViewController {
    var blockUsersId = [String]()
    var blockUsers = [User]()
    var numOfFriends : UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route display"
        tableView.tableFooterView = UIView()
        fetchNumOfFriend()
        fetchCurrentInfo()
        
    }
    
    func fetchNumOfFriend() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
            ref.observeSingleEvent(of: .value) { (snapshot) in
                self.numOfFriends = snapshot.childrenCount
                print(snapshot.childrenCount)
            }
        }
    }
    
    func fetchCurrentInfo() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("locationBlock")
            ref.observe(.value) { (snapshot) in
                self.blockUsersId = []
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    self.blockUsersId.append(child.key)
                }
                
                DispatchQueue.main.async {
                    let refUser = FIRDatabaseReference.root.reference().child("users")
                    refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                        self.blockUsers = []
                        for child in snapshot.children.allObjects as! [DataSnapshot] {
                            for id in self.blockUsersId {
                                if child.key == id {
                                    if let dictionary = child.value as? [String: AnyObject] {
                                        let user = User(dictionary: dictionary)
                                        user.uid = child.key
                                        self.blockUsers.append(user)
                                    }
                                }
                            }
                        }
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .lightGray
        title.text = "Who can see your location and route?"
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        //title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            cell.textLabel?.text = "All friends"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "No one"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Everyone except ..."
        }
        print(blockUsers.count)
        print("num of friend \(numOfFriends)")
        if blockUsersId.count == 0 && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else if blockUsersId.count == numOfFriends && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        } else if blockUsersId.count != 0 && indexPath.row == 2 && blockUsersId.count < numOfFriends{
            cell.accessoryType = .checkmark
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            allFriendAllowed()
        } else if indexPath.row == 1 {
            noFriendAllowed()
        } else if indexPath.row == 2 {
            let chooseFriend = ChoosePrivacy()
            for user in blockUsers {
                chooseFriend.selectUsers.append(user)
            }
            let navController = UINavigationController(rootViewController: chooseFriend)
            present(navController, animated: true, completion: nil)
        }
    }
    
    func allFriendAllowed () {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("locationBlock")
            ref.removeValue()
            for id in blockUsersId {
                let refOther = FIRDatabaseReference.setting(uid: id).reference().child("route").child(currentUser.uid).child("allowed")
                refOther.setValue("yes")
            }
        }
    }
    
    func noFriendAllowed () {
        if let currentUser = Auth.auth().currentUser {
            var friendListId = [String]()
            let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
            ref.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    friendListId.append(child.key)
                    let refOther = FIRDatabaseReference.setting(uid: child.key).reference().child("route").child(currentUser.uid).child("allowed")
                    refOther.setValue("no")
                }
                
                DispatchQueue.main.async {
                    let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("locationBlock")
                    for id in friendListId {
                        ref.updateChildValues([id : "block"])
                    }
                }
            }
        }
    }

}
