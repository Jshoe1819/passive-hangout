//
//  FeedCellDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/1/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol FeedCellDelegate : class {
    func didPressJoinBtn(_ tag: Int)
    func didPressAlreadyJoinedBtn(_ tag: Int)
    func didPressProfilePic(_ tag: Int)
    //profile press
    //content press
}
