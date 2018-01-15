//
//  RoundedButton.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        
        self.alpha = 0.90
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1
        
    }
    
}

