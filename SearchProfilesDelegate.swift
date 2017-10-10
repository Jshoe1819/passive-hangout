//
//  SearchProfilesDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/9/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol SearchProfilesDelegate : class {
    func didPressAddFriendBtn(_ tag: Int)
    func didPressRequestSentBtn (_ tag: Int)
}
