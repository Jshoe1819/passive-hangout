//
//  NewStatusTextView.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/22/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class NewStatusTextView: UITextView {
    
    override func awakeFromNib() {
        
        self.text = ""
        self.textColor = UIColor.white
        self.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument)
//        self.textContainer.maximumNumberOfLines = 3
//        self.textContainer.lineBreakMode = .byClipping
        
    }
    
}
