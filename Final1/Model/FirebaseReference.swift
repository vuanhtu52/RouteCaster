//
//  FirebaseReference.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/23/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import Foundation
import Firebase

enum FIRDatabaseReference {
    case root
    case users(uid: String)
    case groupChat
    case friendList(uid: String)
    case sentRequests(uid: String)
    case sentMess(uid: String)
    case setting(uid: String)
    case route(uid: String)
    
    func reference() -> DatabaseReference{
        switch self {
        case .root:
            return rootRef
        default:
            return rootRef.child(path)
        }
    }
    
    private var rootRef: DatabaseReference {
        return Database.database().reference()
    }
    
    private var path: String {
        switch self {
        case .root:
            return ""
        case .users(let uid):
            return "users/\(uid)"
        case .groupChat:
            return "groupChat"
        case .friendList(let uid):
            return "friendList/\(uid)"
        case .sentRequests(let uid):
            return "sentRequests/\(uid)"
        case .sentMess(let uid):
            return "sentMess/\(uid)"
        case .setting(let uid):
            return "setting/\(uid)"
        case .route(let uid):
            return "route/\(uid)"
        }
    }
}

enum FIRStorageReference {
    case root
    case profileImages
    case staticMap(uid: String)
    func referene() -> StorageReference {
        switch self {
        case .root:
            return rootRef
        default:
            return rootRef.child(path)
        }
    }
    
    private var rootRef: StorageReference {
        return Storage.storage().reference()
    }
    
    private var path: String {
        switch self {
        case .root:
            return ""
        case .profileImages:
            return "profileImages"
        case .staticMap(let uid):
            return "staticMap/\(uid)"
        }
    }
}

