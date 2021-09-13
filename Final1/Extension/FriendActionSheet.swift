//
//  FriendActionSheet.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase
// Extension for ActionSheet
extension BaseSearchTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let profileViewController = segue.destination as? ProfileViewController {
    
                profileViewController.user = (sender as! User)
            }
        }
    }
    
    
    // Present Action Sheet when clicking into user's name
    func defineActionSheet (_ user: User) {
        let actionSheet = UIAlertController(title: "\(String(describing: user.displayedName!))", message: nil, preferredStyle: .actionSheet)
        
        // View User's Profile Action
        let action1 = UIAlertAction(title: "View Profile", style: .default) { (action) in
            //Dismiss the search controller and move to profile page
            self.searchController.isActive = false
            let profile = FriendProfileTableViewController()
            profile.user = user
            self.navigationController?.pushViewController(profile, animated: true)
            //self.performSegue(withIdentifier: "showProfile", sender: user)
        }
        
        // Message Action
        let action2 = UIAlertAction(title: "Message", style: .default) { (action) in
            self.searchController.isActive = false
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            let users: [User] = [user]
            let groupChat = GroupChat(uid: user.uid!, users: users)
            chatLogController.groupChat = groupChat
            self.navigationController?.pushViewController(chatLogController, animated: true)
        }
        
        // Add two actions into action sheet
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        
        // Send friend request/ Add Friend action
        let actionAdd = UIAlertAction(title: "Add friend", style: .default) { (action) in
            //user.baseSearch = self
            user.addFriend()
            let alert = UIAlertController(title: "Request Sent", message: "You have sent request to \(user.displayedName!)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        // Cancel request that has been sent
        let actionCancel = UIAlertAction(title: "Cancel request", style: .destructive) { (action) in
            user.baseSearch = self
            user.removeFriend()
        }
        // Respond to friend request from others
        let actionRespond = UIAlertAction(title: "Respond to Request", style: .default) { (action) in
            user.baseSearch = self
            user.respondRequest()
        }
        // Go to friend setting
        let actionSetting = UIAlertAction(title: "Setting", style: .default) { (action) in
            let friendSetting = FriendSettingTableViewController()
            friendSetting.user = user
            self.navigationController?.pushViewController(friendSetting, animated: true)
        }
        
        //Get the friend status to decide how to perform the action for button 3 on action sheet
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            FIRDatabaseReference.friendList(uid: currentUser.uid).reference().observe(.value) { (snapshot) in
                if (snapshot.hasChild(user.uid!)) {
                    let value = snapshot.value as? NSDictionary
                    let friendStatus = value?.value(forKey: user.uid!) as? String ?? ""
                    if friendStatus == "sent" {
                        actionSheet.addAction(actionCancel)
                    }
                    else if friendStatus == "received" {
                        actionSheet.addAction(actionRespond)
                    }
                    else if friendStatus == "friend" {
                        actionSheet.addAction(actionSetting)
                    }
                } else {
                    actionSheet.addAction(actionAdd)
                }
            }
            
        }
        
        // Cancel Action Sheet
        let action4 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("")
        }
        actionSheet.addAction(action4)
        // Present Action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
}
