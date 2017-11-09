//
//  MessagesCellDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol MessagesCellDelegate : class {
    func didPressUnselectedDeleteBtn(_ tag: Int)
    func didPressSelectedDeleteBtn(_ tag: Int)
}
