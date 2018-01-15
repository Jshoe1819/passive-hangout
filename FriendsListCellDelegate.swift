//
//  FriendsListCellDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/27/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol FriendsListCellDelegate : class {
    //func didPressMenuBtn(_ tag: Int)
    func didPressIgnoreBtn(_ tag: Int)
    func didPressAcceptBtn(_ tag: Int)
}
