//
//  Status.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/14/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import Firebase

class Status {
    
    private var _available: Bool!
    private var _content: String!
    private var _profilePicUrl: String!
    private var _username: String!
    private var _statusKey: String!
    private var _statusRef: DatabaseReference!
    
    var available: Bool {
        return _available
    }
    
    var content: String {
        return _content
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    var username: String {
        return _username
    }
    
    var statusKey: String {
        return _statusKey
    }
    
    init(available: Bool, content: String, profilePicUrl: String, username: String) {
        self._available = available
        self._content = content
        self._profilePicUrl = profilePicUrl
        self._username = username
    }
    
    init(statusKey: String, statusData: Dictionary<String, Any>) {
        self._statusKey = statusKey
        
        if let available = statusData["available"] as? Bool {
            self._available = available
        }
        
        if let content = statusData["content"] as? String {
            self._content = content
        }
        
        if let profilePicUrl = statusData["profilePicUrl"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let username = statusData["userId"] as? String {
            self._username = username
        }
        
        _statusRef = DataService.ds.REF_STATUS.child(_statusKey)
        
    }
    
    
    
}
