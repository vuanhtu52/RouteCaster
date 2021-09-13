//
//  ProfileViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/4/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    var user = User()
    let cellId = "cellId"
    var users = [User]()
    var friendIdList = [String]()
    var friends = [User]()
    //var baseSearch = BaseSearchTableViewController()
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var listFriend: UITableView!
    @IBOutlet weak var addFriend: UIButton!
    @IBOutlet weak var chat: UIButton!
    @IBOutlet weak var setting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAddFriendButton()
        displayName.text = user.displayedName
        // Do any additional setup after loading the view.
        fetchUser()
        saveFriendList(user.uid!)
        listFriend.delegate = self
        listFriend.dataSource = self
        listFriend.register(UserCell.self, forCellReuseIdentifier: cellId)
        if let profileImageURL = user.profileImageURL {
            profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
        }
    }
    
    @IBAction func addDidTap(_ sender: Any) {

        if addFriend.title(for: .normal) == "Add" {
            user.addFriend()
        } else if addFriend.title(for: .normal) == "Unfriend" {
            confirmUnfriend()
        } else if addFriend.title(for: .normal) == "Respond" {
            respondToFriendRequest()
        } else { // Cancel friend request
            user.removeFriend()
        }
    }
    
    @IBAction func chatDidTap(_ sender: Any) {
    }
    
    
    @IBAction func settingDidTap(_ sender: Any) {
    }
    
    func changeAddFriendButton () {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.friendList(uid: currentUser.uid).reference().observe(.value) { (snapshot) in
                if (snapshot.hasChild(self.user.uid!)) {
                    let value = snapshot.value as? NSDictionary
                    let friendStatus = value?.value(forKey: self.user.uid!) as? String ?? ""
                    if friendStatus == "sent" {
                        self.addFriend.setTitle("Cancel", for: .normal)
                        self.addFriend.setTitleColor(UIColor.red, for: .normal)
                    }
                    else if friendStatus == "received" {
                        self.addFriend.setTitle("Respond", for: .normal)
                        self.addFriend.setTitleColor(nil, for: .normal)
                    }
                    else if friendStatus == "friend" {
                        self.addFriend.setTitle("Unfriend", for: .normal)
                        self.addFriend.setTitleColor(UIColor.red, for: .normal)
                    }
                } else {    //Not friend
                    self.addFriend.setTitle("Add", for: .normal)
                    self.addFriend.setTitleColor(nil, for: .normal)
                }
            }
            
        }
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
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Fetch all users data from database except for current user and save it into variable
    func fetchUser () {
        FIRDatabaseReference.root.reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.setUid(uid: snapshot.key)
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.listFriend.reloadData()
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
                self.listFriend.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        user = friends[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        cell.textLabel?.text = user.displayedName
        //cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectUser: User
        
        selectUser = friends[indexPath.row]
        self.performSegue(withIdentifier: "showProfile", sender: selectUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileViewController = segue.destination as? ProfileViewController {
            profileViewController.user = (sender as! User)
        }
    }
}

