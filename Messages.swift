//
//  Messages.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Messages {
    
    private var _content: String!
    private var _senderuid: String!
    //private var _profilePicUrl: String!
    //private var _username: String!
    private var _timestamp: Double!
    private var _messageKey: String!
    private var _messageRef: DatabaseReference!
    
    var content: String {
        return _content
    }
    
    var senderuid: String {
        return _senderuid
    }
    
    var timestamp: Double {
        return _timestamp
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(content: String, senderuid: String, timestamp: Double, messageKey: String) {
        self._content = content
        self._senderuid = senderuid
        self._timestamp = timestamp
        self._messageKey = messageKey
    }
    
    init(messageKey: String, messageData: Dictionary<String, Any>) {
        self._messageKey = messageKey
        
        if let content = messageData["content"] as? String {
            self._content = content
        }
        
        if let senderuid = messageData["senderuid"] as? String {
            self._senderuid = senderuid
        }
        
        if let timestamp = messageData["timestamp"] as? Double {
            self._timestamp = timestamp
        }
        
        _messageRef = DataService.ds.REF_MESSAGES.child(messageKey)
        
    }
    
}
