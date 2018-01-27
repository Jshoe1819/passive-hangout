//
//  MutedConvosDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 1/27/18.
//  Copyright © 2018 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol MutedConvosDelegate : class {
    func mutedSwitchOn(_ tag: Int)
    func mutedSwitchOff(_ tag: Int)
}
