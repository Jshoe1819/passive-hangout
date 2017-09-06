//
//  Users.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/16/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Users {
    
    private var _cover: Dictionary<String, Any>!
    private var _email: String!
    private var _id: String!
    private var _name: String!
    private var _statusId: Dictionary<String, Any>!
    private var _profilePicUrl: String!
    private var _usersKey: String!
    private var _usersRef: DatabaseReference!
    
    var cover: Dictionary<String, Any> {
        return _cover
    }
    
    var email: String {
        return _email
    }
    
    var id: String {
        return _id
    }
    
    var name: String {
        return _name
    }
    
    var statusId: Dictionary<String, Any> {
        return _statusId
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    init(cover: Dictionary<String, Any>, email: String, id: String, name: String, statusId: Dictionary<String, Any>) {
        self._cover = cover
        self._email = email
        self._id = id
        self._name = name
        self._statusId = statusId
        self._profilePicUrl = profilePicUrl
        
    }
    
    init(usersKey: String, usersData: Dictionary<String, Any>) {
        self._usersKey = usersKey
        
        if let cover = usersData["cover"] as? Dictionary<String, Any> {
            self._cover = cover
        }
        
        if let email = usersData["email"] as? String {
            self._email = email
        }
        
        if let name = usersData["name"] as? String {
            self._name = name
        }
        
        if let statusId = usersData["statusId"] as? Dictionary<String, Any> {
            self._statusId = statusId
        }
        
        if let profilePicUrl = usersData["profilePicUrl"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        _usersRef = DataService.ds.REF_USERS.child(_usersKey)
        
    }
    
    
    
}
