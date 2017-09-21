//
//  PastStatusCellDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/19/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

protocol PastStatusCellDelegate : class {
    func didPressEditBtn(_ tag: Int)
    func didPressDeleteBtn(_ tag: Int)
    func didPressSaveBtn(_ tag: Int)
    func didPressCancelBtn(_ tag: Int)
}
