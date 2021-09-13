//
//  ChoosePeopleViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/1/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChoosePeopleViewController: BaseSearchTableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(handleOk))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        setUpTableView()
        fetchUser()
        getFriendList()
        
    }
    
    func setUpTableView () {
        self.searchController = UISearchController(searchResultsController: resultController)
        tableView.tableHeaderView = self.searchController.searchBar
        tableView.register(MultipleUserCell.self, forCellReuseIdentifier: cellId)
        self.searchController.searchResultsUpdater = self
        
        self.resultController.tableView.delegate = self
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.register(MultipleUserCell.self, forCellReuseIdentifier: cellId)
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsSelectionDuringEditing = true
        self.resultController.tableView.allowsMultipleSelection = true
        self.resultController.tableView.allowsSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView
        {
            return self.filterUsers.count
        }
        else
        {
            return self.users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MultipleUserCell
        if tableView == resultController.tableView
        {
            user = self.filterUsers[indexPath.row]
            for selectUser in selectUsers {
                if selectUser.uid == user.uid {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                    tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
                }
            }
        }
        else
        {
            user = users[indexPath.row]
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
            let selectFriend = filterUsers[indexPath.row]
            for selectUser in selectUsers {
                if selectFriend.uid == selectUser.uid {
                    return
                }
            }
            selectUsers.append(selectFriend)
            for (index, user) in users.enumerated() {
                if selectFriend.uid == user.uid {
                    let indexPath = NSIndexPath(row: index, section: 0)
                    self.tableView.cellForRow(at: indexPath as IndexPath)!.accessoryType = .checkmark
                }
            }
        }
        else {
            let selectFriend = users[indexPath.row]
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
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var index = -1
        if tableView == self.tableView {
            for user in self.selectUsers {
                if user.email == self.users[indexPath.row].email {
                    index = self.selectUsers.index(of: user) ?? -1
                }
            }
            if index >= 0 {
                self.selectUsers.remove(at: index)
            }
        } else {
            for user in self.selectUsers {
                if user.email == self.filterUsers[indexPath.row].email {
                    index = self.selectUsers.index(of: user) ?? -1
                }
            }
            if index >= 0 {
                self.selectUsers.remove(at: index)
            }
            let deSelect = self.filterUsers[indexPath.row]
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
        let groupChat: GroupChat?
        if selectUsers.count == 1 {
            groupChat = GroupChat(uid: selectUsers[0].uid!, users: selectUsers)
        }
        
        else {
            let ref = FIRDatabaseReference.groupChat.reference().childByAutoId()
            for selectUser in selectUsers {
                ref.updateChildValues(["\(selectUser.uid!)" : 1])
            }
            if let currentUser = Auth.auth().currentUser {
                ref.updateChildValues([currentUser.uid: 1])
            }
            groupChat = GroupChat(uid: ref.key!, users: selectUsers)
        }
        dismiss(animated: true) {
            let groupChat = groupChat
            self.chatList?.showChatLog(groupChat!)
        }
        
    }
    
}



