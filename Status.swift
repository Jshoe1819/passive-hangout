//
//  Status.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/14/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Status {
    
    private var _available: Bool!
    private var _content: String!
    //private var _profilePicUrl: String!
    //private var _username: String!
    private var _joinedList: Dictionary<String, Any>!
    private var _joinedNumber: Int!
    private var _userId: String!
    private var _postedDate: Double!
    private var _statusKey: String!
    private var _statusRef: DatabaseReference!
    
    var available: Bool {
        return _available
    }
    
    var content: String {
        return _content
    }
    
    var joinedList: Dictionary<String, Any> {
        return _joinedList
    }
    
    var joinedNumber: Int {
        return _joinedNumber
    }
    
    var userId: String {
        return _userId
    }
    
    var postedDate: Double {
        return _postedDate
    }
    
    var statusKey: String {
        return _statusKey
    }
    
    init(available: Bool, content: String, joinedList: Dictionary<String,Any>, joinedNumber: Int, userId: String, postedDate: Double) {
        self._available = available
        self._content = content
        self._joinedList = joinedList
        self._joinedNumber = joinedNumber
        self._userId = userId
        self._postedDate = postedDate
    }
    
    init(statusKey: String, statusData: Dictionary<String, Any>) {
        self._statusKey = statusKey
        
        if let available = statusData["available"] as? Bool {
            self._available = available
        }
        
        if let content = statusData["content"] as? String {
            self._content = content
        }
        
        if let joinedList = statusData["joinedList"] as? Dictionary<String,Any> {
            self._joinedList = joinedList
        }
        
        if let joinedNumber = statusData["joinedNumber"] as? Int {
            self._joinedNumber = joinedNumber
        }
        
        if let userId = statusData["userId"] as? String {
            self._userId = userId
        }
        
        if let postedDate = statusData["postedDate"] as? Double {
            self._postedDate = postedDate
        }
        
        _statusRef = DataService.ds.REF_STATUS.child(_statusKey)
        
    }
    
    
    
}
