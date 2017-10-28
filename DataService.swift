//
//  DataService.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_STATUS = DB_BASE.child("status")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_CONVERSATION = DB_BASE.child("conversations")
    private var _REF_STATUS_UID = DB_BASE.child("status").child("userId")
    
    //Storage references
    private var _REF_STORAGE_BASE = STORAGE_BASE
    private var _REF_BACKGROUND_PICTURES = STORAGE_BASE.child("background-pictures")
    private var _REF_PROFILE_PICTURES = STORAGE_BASE.child("profile-pictures")
    //add one for profile pictures
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_STATUS: DatabaseReference {
        return _REF_STATUS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_CONVERSATION: DatabaseReference {
        return _REF_CONVERSATION
    }
    
    var REF_STATUS_UID: DatabaseReference {
        return _REF_STATUS_UID
    }
    
    var REF_STORAGE_BASE: StorageReference {
        return _REF_STORAGE_BASE
    }
    
    var REF_BACKGROUND_PICTURES: StorageReference {
        return _REF_BACKGROUND_PICTURES
    }
    
    var REF_PROFILE_PICTURES: StorageReference {
        return _REF_PROFILE_PICTURES
    }
    
    //    var REF_USER_CURRENT: DatabaseReference {
    //        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
    //        let user = REF_USERS.child(uid!)
    //        return user
    //    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }

    

    
    
    
}
