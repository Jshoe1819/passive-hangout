//
//  SearchHangoutsDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/24/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol SearchHangoutsDelegate : class {
    func didPressJoinBtn(_ tag: Int)
    func didPressAlreadyJoinedBtn(_ tag: Int)
}
