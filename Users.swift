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
    private var _friendsList: Dictionary<String, Any>!
    private var _joinedList: Dictionary<String, Any>!
    private var _profilePicUrl: String!
    private var _isPrivate: Bool!
    private var _occupation: String!
    private var _employer: String!
    private var _currentCity: String!
    private var _school: String!
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
    
    var friendsList: Dictionary<String, Any> {
        return _friendsList
    }
    
    var joinedList: Dictionary<String, Any> {
        return _joinedList
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    var isPrivate: Bool {
        return _isPrivate
    }
    
    var occupation: String {
        return _occupation
    }
    
    var employer: String {
        return _employer
    }
    
    var currentCity: String {
        return _currentCity
    }
    
    var school: String {
        return _school
    }
    
    var usersKey: String {
        return _usersKey
    }
    
    
    init(cover: Dictionary<String, Any>, email: String, id: String, name: String, statusId: Dictionary<String, Any>, friendsList: Dictionary<String, Any>, joinedList: Dictionary<String, Any>, profilePicUrl: String, isPrivate: Bool, occupation: String, employer: String, currentCity: String, school: String, usersKey:String) {
        self._cover = cover
        self._email = email
        self._id = id
        self._name = name
        self._statusId = statusId
        self._friendsList = friendsList
        self._joinedList = joinedList
        self._profilePicUrl = profilePicUrl
        self._isPrivate = isPrivate
        self._occupation = occupation
        self._employer = employer
        self._currentCity = currentCity
        self._school = school
        self._usersKey = usersKey
        
    }
    
    init(usersKey: String, usersData: Dictionary<String, Any>) {
        self._usersKey = usersKey
        
        if let cover = usersData["cover"] as? Dictionary<String, Any> {
            self._cover = cover
        }
        
        if let email = usersData["email"] as? String {
            self._email = email
        }
        
        if let id = usersData["id"] as? String {
            self._id = id
        }
        
        if let name = usersData["name"] as? String {
            self._name = name
        }
        
        if let statusId = usersData["statusId"] as? Dictionary<String, Any> {
            self._statusId = statusId
        }
        
        if let friendsList = usersData["friendsList"] as? Dictionary<String, Any> {
            self._friendsList = friendsList
        }
        
        if let joinedList = usersData["joinedList"] as? Dictionary<String, Any> {
            self._joinedList = joinedList
        }
        
        if let profilePicUrl = usersData["profilePicUrl"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let isPrivate = usersData["isPrivate"] as? Bool {
            self._isPrivate = isPrivate
        }
        
        if let occupation = usersData["occupation"] as? String {
            self._occupation = occupation
        }
        
        if let employer = usersData["employer"] as? String {
            self._employer = employer
        }
        
        if let currentCity = usersData["currentCity"] as? String {
            self._currentCity = currentCity
        }
        
        if let school = usersData["school"] as? String {
            self._school = school
        }
        
        _usersRef = DataService.ds.REF_USERS.child(_usersKey)
        
    }
    
    
    
}
