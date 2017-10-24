//
//  SearchCitiesDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/24/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol SearchCitiesDelegate : class {
    func didPressAddFriendBtn(_ tag: Int)
    func didPressRequestSentBtn (_ tag: Int)
    
}
