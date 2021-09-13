//
//  TableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/13/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class NotiTableViewController: UITableViewController {

    var friendRequestId = [String]()
    var friendRequest = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFriendStatus()
        let nib = UINib.init(nibName: "RespondTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RespondTableViewCell")
    }
    
    func fetchFriendStatus () {
        let friendMana = FriendManagement()
        friendMana.fetchUser { (complete) in
            if complete {
                if let currentUser = Auth.auth().currentUser {
                    FIRDatabaseReference.friendList(uid: currentUser.uid).reference().observe(.value) { (snapshot) in
                        self.friendRequestId = []
                        self.friendRequest = []
                        for child in snapshot.children.allObjects as! [DataSnapshot] {
                            let value = child.value as? String ?? ""
                            if value == "received" {
                                self.friendRequestId.append(child.key)
                            }
                        }
                        DispatchQueue.main.async(execute: {
                            for user in friendMana.users {
                                print(user.displayedName!)
                                for id in self.friendRequestId {
                                    if user.uid! == id {
                                        self.friendRequest.append(user)
                                    }
                                }
                            }
                            self.tableView.reloadData()
                        })
                    }
                }

            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendRequest.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RespondTableViewCell", for: indexPath) as! RespondTableViewCell

        cell.notiContent.text = "\(friendRequest[indexPath.row].displayedName!) has sent you a friend request"
        if let profileImageURL = friendRequest[indexPath.row].profileImageURL {
            cell.profileImage.loadImageUsingCacheWithUrlString(profileImageURL)
        }
        
        // Define action when btn being tapped
        cell.acceptBtnTapped = { [unowned self] in
            self.friendRequest[indexPath.row].acceptRequest()
        }
        cell.declineBtnTapped = { [unowned self] in
            self.friendRequest[indexPath.row].removeFriend()
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = FriendProfileTableViewController()
        profile.user = friendRequest[indexPath.row]
        self.navigationController?.pushViewController(profile, animated: true)
    }

}
