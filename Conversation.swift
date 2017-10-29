//
//  Conversation.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Conversation {
    
    private var _details: Dictionary<String, Any>!
    private var _messages: Dictionary<String, Any>!
    //private var _profilePicUrl: String!
    //private var _username: String!
    private var _users: Dictionary<String, Any>!
    private var _conversationKey: String!
    private var _conversationRef: DatabaseReference!
    
    var details: Dictionary<String, Any> {
        return _details
    }
    
    var messages: Dictionary<String, Any> {
        return _messages
    }
    
    var users: Dictionary<String, Any> {
        return _users
    }
    
    var conversationKey: String {
        return _conversationKey
    }
    
    init(details: Dictionary<String, Any>!, messages: Dictionary<String, Any>!, users: Dictionary<String,Any>, conversationKey: String) {
        self._details = details
        self._messages = messages
        self._users = users
        self._conversationKey = conversationKey
    }
    
    init(conversationKey: String, conversationData: Dictionary<String, Any>) {
        self._conversationKey = conversationKey
        
        if let details = conversationData["details"] as? Dictionary<String, Any> {
            self._details = details
        }
        
        if let messages = conversationData["messages"] as? Dictionary<String, Any> {
            self._messages = messages
        }
        
        if let users = conversationData["users"] as? Dictionary<String,Any> {
            self._users = users
        }
        
        _conversationRef = DataService.ds.REF_CONVERSATION.child(_conversationKey)
        
    }
    
}
