//
//  RoundedPopUp.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/22/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class RoundedPopUp: UIView {
    
    override func awakeFromNib() {
        
        self.layer.cornerRadius = 8.0
        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.9)
        
    }
}
