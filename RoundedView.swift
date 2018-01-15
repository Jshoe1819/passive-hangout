//
//  RoundedView.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/9/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    override func awakeFromNib() {
        
        self.layer.cornerRadius = 8.0
        self.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        
    }
    
    
}
