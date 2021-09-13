//
//  ChooseFriendTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChooseFriendTableViewController: BaseSearchTableViewController {

    var filterFriends = [User]()
    var allowMultipleSelection: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in choose friend")
        for user in selectUsers {
            print(user.displayedName!)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(handleOk))
        self.searchController = UISearchController(searchResultsController: resultController)
        tableView.tableHeaderView = self.searchController.searchBar
        tableView.register(MultipleUserCell.self, forCellReuseIdentifier: cellId)
        self.searchController.searchResultsUpdater = self
        
        self.resultController.tableView.delegate = self
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.register(MultipleUserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        getFriendList()
        allowMulipleSelect(allowMultipleSelection)
    }
    
    func allowMulipleSelect (_ bool: Bool) {
        self.tableView.allowsMultipleSelection = bool
        self.tableView.allowsSelectionDuringEditing = bool
        self.resultController.tableView.allowsMultipleSelection = bool
        self.resultController.tableView.allowsSelectionDuringEditing = bool
    }
    
    override func updateSearchResults(for searchController: UISearchController) {
        self.filterFriends = friends.filter({ (user: User) -> Bool in
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView
        {
            return self.filterFriends.count
        }
        else
        {
            return self.friends.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MultipleUserCell
        if tableView == resultController.tableView
        {
            user = self.filterFriends[indexPath.row]
        }
        else
        {
            user = friends[indexPath.row]
        }
        for selectUser in selectUsers {
            print(user.uid!)
            print(selectUser.uid!)
            if selectUser.uid == user.uid {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            }
        }
        cell.textLabel?.text = user.displayedName
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    var chatList: ChatListTableViewController?
    
    var selectUsers = [User]()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == resultController.tableView {
            let selectFriend = filterFriends[indexPath.row]
            for selectUser in selectUsers {
                if selectFriend.uid == selectUser.uid {
                    return
                }
            }
            selectUsers.append(selectFriend)
            for (index, friend) in friends.enumerated() {
                if selectFriend.uid == friend.uid {
                    let indexPath = NSIndexPath(row: index, section: 0)
                    self.tableView.cellForRow(at: indexPath as IndexPath)!.accessoryType = .checkmark
                }
            }
            
        }
        else {
            let selectFriend = friends[indexPath.row]
            for selectUser in selectUsers {
                if selectFriend.uid == selectUser.uid {
                    return
                }
            }
            selectUsers.append(selectFriend)
        }
        
        if (selectUsers.count != 0) {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        for user in selectUsers {
            print(user.displayedName!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var index = -1
        if tableView == self.tableView {
            for user in self.selectUsers {
                if user.email == self.friends[indexPath.row].email {
                    index = self.selectUsers.index(of: user) ?? -1
                }
            }
            if index >= 0 {
                self.selectUsers.remove(at: index)
            }
        } else {
            for user in self.selectUsers {
                if user.email == self.filterFriends[indexPath.row].email {
                    index = self.selectUsers.index(of: user) ?? -1
                }
            }
            if index >= 0 {
                self.selectUsers.remove(at: index)
            }
            let deSelect = self.filterFriends[indexPath.row]
            for (index, friend) in friends.enumerated() {
                if deSelect.uid == friend.uid {
                    let indexPath = NSIndexPath(row: index, section: 0)
                    self.tableView.cellForRow(at: indexPath as IndexPath)!.accessoryType = .none
                }
            }
        }
        if (selectUsers.count == 0) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func handleOk() {
        for user in selectUsers {
            print(user.displayedName!)
        }
    }
    
    
}

class ChooseOneFriendTableViewController: ChooseFriendTableViewController {
    override func viewDidLoad() {
        allowMultipleSelection = false
        super.viewDidLoad()
    }
    
}

class ChooseMultipleFriendTableViewControler: ChooseFriendTableViewController {
    override func viewDidLoad() {
        allowMultipleSelection = true
        super.viewDidLoad()
    }
}

class ChooseShareInApp : ChooseMultipleFriendTableViewControler {
    var sharedObjects: [Any]!
    
    @objc override func handleOk() {
        let text = "\(sharedObjects!)"
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.inputTextField.text = text
        for selectUser in selectUsers {
            chatLogController.groupChat = GroupChat(uid: selectUser.uid!, users: selectUsers)
            chatLogController.handleSend()
        }
        //performSegue(withIdentifier: "homeView", sender: nil)
        
        navigationController?.pushViewController(chatLogController, animated: true)
        self.dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard(name: "ROUTECASTER", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ROUTECASTER") as! HomeViewController
        present(vc, animated: true, completion: nil)
    }
}

class ChooseRoute : ChooseMultipleFriendTableViewControler {
    @objc override func handleOk() {
        if let currentUser = Auth.auth().currentUser {
            let refSetting = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route")
            refSetting.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    var isAllow = false
                    for user in self.selectUsers {
                        if child.key == user.uid {
                            isAllow = true
                            break
                        }
                    }
                    if !isAllow {
                        refSetting.child(child.key).child("displayOnMap").setValue("no")
                    } else {
                        refSetting.child(child.key).child("displayOnMap").setValue("yes")
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

class ChoosePrivacy : ChooseMultipleFriendTableViewControler {
    @objc override func handleOk() {
        if let currentUser = Auth.auth().currentUser {
            let refSetting = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("locationBlock")
            refSetting.removeValue()
            
            if let currentUser = Auth.auth().currentUser {
                let ref = FIRDatabaseReference.friendList(uid: currentUser.uid).reference()
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        let refOther = FIRDatabaseReference.setting(uid: child.key).reference().child("route").child(currentUser.uid).child("allowed")
                        refOther.setValue("yes")
                    }
                    DispatchQueue.main.async {
                        for user in self.selectUsers {
                            print("HIII")
                            print(user.displayedName!)
                            refSetting.updateChildValues([user.uid! : "block"])
                            print(user.uid!)
                            print(currentUser.uid)
                            let refOther = FIRDatabaseReference.setting(uid: user.uid!).reference().child("route").child(currentUser.uid).child("allowed")
                            refOther.setValue("no")
                        }
                    }
                }
            }
            
            
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}
