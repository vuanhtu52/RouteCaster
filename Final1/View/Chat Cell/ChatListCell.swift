//
//  UserCell.swift
//  gameofchats
//
//  Created by Brian Voong on 7/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class ChatListCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        var isGroup = false
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        detailTextLabel?.textColor = UIColor.gray
        FIRDatabaseReference.groupChat.reference().observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild((self.message?.toId!)!) {
                isGroup = true
                print("hasChild")
            }
            
            DispatchQueue.main.async {
                var chatPartnerId = ""
                if isGroup {
                    chatPartnerId = (self.message?.toId!)!
                } else {
                    chatPartnerId = (self.message?.fromId == Auth.auth().currentUser?.uid ? self.message!.toId : self.message!.fromId)!
                }
                let ref = Database.database().reference().child("users")
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !isGroup {
                        let value = snapshot.value as? NSDictionary
                        let dictionary = value?[chatPartnerId] as? NSDictionary
                        self.textLabel?.text = dictionary?["displayedName"] as? String ?? ""
                        
                        if let profileImageUrl = dictionary?["profileImageURL"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                        }
                        
                    } else {
                        //self.textLabel?.text = "Group chat"
                        var userIds = [String]()
                        let refGroup = Database.database().reference().child("groupChat").child(chatPartnerId)
                        refGroup.observeSingleEvent(of: .value, with: { (snapshot) in
                            print("in refGroup")
                            print(snapshot)
                            for child in snapshot.children.allObjects as! [DataSnapshot] {
                                print(child.key)
                                userIds.append(child.key)
                            }
                            var groupName = ""
                            //completion(true)
                            DispatchQueue.main.async {
                                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                                        for userId in userIds {
                                            if userId == child.key {
                                                guard let dictionary = child.value as? [String: AnyObject] else {
                                                    return
                                                }
                                                let user = User(dictionary: dictionary)
                                                user.uid = child.key
                                                groupName = groupName + user.displayedName! + ", "
                                            }
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        groupName.removeLast()
                                        groupName.removeLast()
                                        print("GROUP NAMEE")
                                        print(groupName)
                                        
                                        if groupName.count > 20 {
                                            let range = groupName.index(groupName.endIndex, offsetBy: 20 - groupName.count)..<groupName.endIndex
                                            groupName.removeSubrange(range)
                                            self.textLabel?.text = groupName + "..."
                                        }
                                        else {
                                            self.textLabel?.text = groupName
                                        }
                                    }
                                    
                                }, withCancel: nil)
                            }
                        }, withCancel: nil)
                    }
                })
            }
            
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        detailTextLabel?.textColor = UIColor.gray
    }
}
