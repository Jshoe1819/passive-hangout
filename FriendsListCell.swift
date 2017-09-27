//
//  FriendsListCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/27/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class FriendsListCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var secondaryLbl: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var separatorDotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
