//
//  ChatListTableViewController.swift
//  Final1
//
//  Created by Tu Vu on 5/10/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ChatListTableViewController: UITableViewController {
    
    var cellId = "cellId"
    //var selectUser = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(choosePeople))
        
        tableView.register(ChatListCell.self, forCellReuseIdentifier: cellId)
        observeUserMessages()
    }
    
    @objc func choosePeople() {
        let choosePeople = ChoosePeopleViewController()
        choosePeople.chatList = self
        let navController = UINavigationController(rootViewController: choosePeople)
        present(navController, animated: true, completion: nil)
    }
    
    func showChatLog(_ groupChat: GroupChat) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.groupChat = groupChat
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                var isGroup = false
                FIRDatabaseReference.groupChat.reference().observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.hasChild(message.toId!) {
                        isGroup = true
                        print("hasChild")
                    }
                    
                    DispatchQueue.main.async {
                        var chatPartnerId = ""
                        if isGroup {
                            chatPartnerId = message.toId!
                        } else {
                            chatPartnerId = (message.fromId == Auth.auth().currentUser?.uid ? message.toId : message.fromId)!
                        }
                        print("chat partner id " + chatPartnerId)
                        self.messagesDictionary[chatPartnerId] = message
                        self.attemptReloadOfTable()
                        
                    }
                }
            }
            
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        var isGroup = false
        FIRDatabaseReference.groupChat.reference().observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(message.toId!) {
                isGroup = true
            }
            
            DispatchQueue.main.async {
                var chatPartnerId = ""
                if isGroup {
                    chatPartnerId = message.toId!
                } else {
                    chatPartnerId = (message.fromId == Auth.auth().currentUser?.uid ? message.toId : message.fromId)!
                }
                if let currentUser = Auth.auth().currentUser {
                    
                    let ref = FIRDatabaseReference.sentMess(uid: currentUser.uid).reference().child(chatPartnerId)
                    ref.observeSingleEvent(of: .value) { (snapshot) in
                        let value = snapshot.value as? String ?? ""
                        if value == "read" || value == "unread" {
                            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                            cell.detailTextLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                        }
                        
                    }
                }
                
            }
        }
        
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        var isGroup = false
        FIRDatabaseReference.groupChat.reference().observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(message.toId!) {
                isGroup = true
            }
            
            DispatchQueue.main.async {
                var chatPartnerId = ""
                if isGroup {
                    chatPartnerId = message.toId!
                } else {
                    chatPartnerId = (message.fromId == Auth.auth().currentUser?.uid ? message.toId : message.fromId)!
                }
                
                let ref = FIRDatabaseReference.sentMess(uid: Auth.auth().currentUser!.uid).reference().child(chatPartnerId)
                ref.removeValue()
                
                let refUser = Database.database().reference().child("users")
                refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(chatPartnerId) {
                        refUser.child(chatPartnerId).observeSingleEvent(of: .value, with: { (snapshot) in
                            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                                return
                            }
                            let user = User(dictionary: dictionary)
                            user.uid = chatPartnerId
                            let users: [User] = [user]
                            let groupChat = GroupChat(uid: chatPartnerId, users: users)
                            self.showChatLog(groupChat)
                            return
                        }, withCancel: nil)
                    }
                    else {
                        var userIds = [String]()
                        let refGroup = Database.database().reference().child("groupChat").child(chatPartnerId)
                        refGroup.observeSingleEvent(of: .value, with: { (snapshot) in
                            print("in refGroup")
                            print(snapshot)
                            for child in snapshot.children.allObjects as! [DataSnapshot] {
                                print(child.key)
                                userIds.append(child.key)
                            }
                            DispatchQueue.main.async {
                                for userId in userIds {
                                    print(userId)
                                }
                                var users = [User]()
                                refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                                        for userId in userIds {
                                            print(child.key)
                                            if userId == child.key {
                                                guard let dictionary = child.value as? [String: AnyObject] else {
                                                    return
                                                }
                                                let user = User(dictionary: dictionary)
                                                user.uid = child.key
                                                users.append(user)
                                            }
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        let groupChat = GroupChat(uid: chatPartnerId, users: users)
                                        self.showChatLog(groupChat)
                                    }
                                    
                                }, withCancel: nil)
                            }
                        }, withCancel: { error in
                            print(error)
                        })
                    }
                })
            }
            
        }
        
        
    }
    
}
