//
//  PastStatusCellDelegate.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/19/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import UIKit

protocol PastStatusCellDelegate : class {
    //func didPressMenuBtn(_ tag: Int, textView: UITextView, label: UILabel, button: UIButton)
    func didPressJoinBtn(_ tag: Int)
    func didPressAlreadyJoinedBtn(_ tag: Int)
    func didPressJoinedList(_ tag: Int)
    //func didPressEditBtn(_ tag: Int)
    //func didPressDeleteBtn(_ tag: Int)
    //func didPressSaveBtn(_ tag: Int, text: String)
    //func didPressCancelBtn(_ tag: Int)
}
