//
//  FriendProfileTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class FriendProfileTableViewController: UITableViewController {
    
    var profileHeader: ProfileHeaderTableViewCell!
    
    var user: User!
    let cellId = "cellId"
    var users = [User]()
    var friendIdList = [String]()
    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "ProfileHeaderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ProfileHeaderTableViewCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        saveFriendList(user.uid!)
        tableView.delegate = self
        tableView.dataSource = self
        changeAddFriendButton()
        configureHeader()
    }
    
    func configureHeader () {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.friendList(uid: currentUser.uid).reference().observe(.value) { (snapshot) in
                if (snapshot.hasChild(self.user.uid!)) {
                    let value = snapshot.value as? NSDictionary
                    let friendStatus = value?.value(forKey: self.user.uid!) as? String ?? ""
                    if friendStatus == "sent" {
                        cell.friend.setTitle("Cancel", for: .normal)
                        cell.friend.setTitleColor(UIColor.red, for: .normal)
                    }
                    else if friendStatus == "received" {
                        cell.friend.setTitle("Respond", for: .normal)
                        cell.friend.setTitleColor(nil, for: .normal)
                    }
                    else if friendStatus == "friend" {
                        cell.friend.setTitle("Unfriend", for: .normal)
                        cell.friend.setTitleColor(UIColor.red, for: .normal)
                    }
                } else {    //Not friend
                    cell.friend.setTitle("Add", for: .normal)
                    cell.friend.setTitleColor(nil, for: .normal)
                }
            }
            
        }
        if let profileImageURL = user.profileImageURL {
            print(profileImageURL)
            cell.profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
        }
        cell.changeFriendStatus = { [unowned self] in
            if cell.friend.title(for: .normal) == "Add" {
                self.user.addFriend()
            } else if cell.friend.title(for: .normal) == "Unfriend" {
                self.confirmUnfriend()
            } else if cell.friend.title(for: .normal) == "Respond" {
                self.respondToFriendRequest()
            } else { // Cancel friend request
                self.user.removeFriend()
            }
        }
        
        cell.name.text = user.displayedName!
        tableView.tableHeaderView = cell
    }
    
    func changeAddFriendButton () {
        
    }
    
    func confirmUnfriend() {
        let alert = UIAlertController(title: nil, message: "Do you want to unfriend this person?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            self.user.removeFriend()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func respondToFriendRequest () {
        let alert = UIAlertController(title: nil, message: "Do you want to add this person?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Accept", style: .default) { (okAction) in
            self.user.acceptRequest()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Decline", style: .default) {
            (cancelAction) in
            self.user.removeFriend()
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friend list"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        user = friends[indexPath.row ]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        cell.textLabel?.text = user.displayedName
        //cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectUser: User
        selectUser = friends[indexPath.row]
        let profile = FriendProfileTableViewController()
        profile.user = selectUser
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    
    // Fetch all users data from database except for current user and save it into variable
    func fetchUser () {
        FIRDatabaseReference.root.reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.setUid(uid: snapshot.key)
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
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
            })
        }
    }
    
}


