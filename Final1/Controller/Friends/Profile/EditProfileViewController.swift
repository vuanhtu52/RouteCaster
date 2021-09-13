//
//  EditProfileViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/9/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class EditProfileTableViewController: UITableViewController {
    let infoCell = "infoCell"
    var user = User()
    var tempProfileImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        fetchUser()
        //tableView.register(InfoCell.self, forCellReuseIdentifier: infoCell)
        let nib = UINib.init(nibName: "AvatarTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AvatarTableViewCell")
        let nib2 = UINib.init(nibName: "InfoTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "InfoTableViewCell")
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        print("in view did load edit")
    }
    
    // Fetch current user information
    func fetchUser () {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.root.reference().child("users").observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let tempUser = User(dictionary: dictionary)
                    tempUser.setUid(uid: snapshot.key)
                    if (currentUser.uid == tempUser.uid) {
                        self.user = tempUser
                    }
                    
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }, withCancel: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let name = user.displayedName,
            let email = user.email,
            let username = user.username,
            let profileImageUrl = user.profileImageURL {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarTableViewCell") as! AvatarTableViewCell
                
                cell.profileImage.loadImageUsingCacheWithUrlString(profileImageUrl)
                cell.changeAvaButtonAction = { [unowned self] in
                    self.handleSelectProfileImageView()
//                    cell.profileImage.loadImageUsingCacheWithUrlString(self.user.profileImageURL!)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as! InfoTableViewCell
                if (indexPath.row == 1) {
                    cell.label.text = "Name"
                    cell.content.text = name
                } else if (indexPath.row == 2) {
                    cell.label.text = "Username"
                    cell.content.text = username
                } else if (indexPath.row == 3) {
                    cell.label.text = "Email"
                    cell.content.text = email
                } else if (indexPath.row == 4) {
                    cell.label.text = "Password"
                    cell.content.text = "************"
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {return 173}
        return 73
    }
    
    //var setting: MainSettingTableViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editOneInfo = storyboard.instantiateViewController(withIdentifier: "editOneInfo") as! EditOneInfoViewController
            editOneInfo.user = user
            if (indexPath.row == 1) {
                editOneInfo.title = "Name"
            } else if (indexPath.row == 2) {
                editOneInfo.title = "Username"
            } else if (indexPath.row == 3) {
                editOneInfo.title = "Email"
            } else if (indexPath.row == 4) {
                editOneInfo.title = "Password"
            }
            editOneInfo.editInfo = self
            self.navigationController?.pushViewController(editOneInfo, animated: true)
        }
    }

}

