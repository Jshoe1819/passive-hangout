//
//  MsgBubbleLabel.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/6/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class MsgBubbleLabel: UILabel {
    
    override func awakeFromNib() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.sizeToFit()
    }
    
    let topInset = CGFloat(2)
    let bottomInset = CGFloat(2)
    let leftInset = CGFloat(10)
    let rightInset = CGFloat(10)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    
}
