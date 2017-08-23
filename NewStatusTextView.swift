//
//  NewStatusTextView.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/22/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class NewStatusTextView: UITextView, UITextViewDelegate {
    
    
    
    override func awakeFromNib() {
        
        
        self.text = "Let's go hiking, camping, to a concert, play some hicket, grab a beer, etc."
        self.textColor = UIColor.white
        self.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        self.contentSize = self.bounds.size
        
        
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.font == UIFont(name: "AvenirNext-UltralightItalic", size: 16) {
            textView.text = nil
            textView.font = UIFont(name: "AvenirNext-Regular", size: 16)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Let's go hiking, camping, to a concert, play some hicket, grab a beer, etc."
            textView.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        }
    }
    
    
    //    func textViewDidBeginEditing(textView: UITextView) {
    //        if textView.font == UIFont(name: "AvenirNext-UltralightItalic", size: 16) {
    //            textView.text = nil
    //            textView.font = UIFont(name: "AvenirNext-Regular", size: 16)
    //        }
    //    }
    //
    //    func textViewDidEndEditing(textView: UITextView) {
    //        if textView.text.isEmpty {
    //            textView.text = "Let's go hiking, camping, to a concert, play some hicket, grab a beer, etc."
    //            textView.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
    //        }
    //    }
    
    
    
}
