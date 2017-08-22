//
//  CircleButton.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/22/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    override func awakeFromNib() {
        
        //self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        //self.backgroundColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        self.alpha = 0.90
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        //self.layer.borderColor
    }
}
