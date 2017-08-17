//
//  FeedProfilePic.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class FeedProfilePic: UIImageView {

    override func awakeFromNib() {
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

}
