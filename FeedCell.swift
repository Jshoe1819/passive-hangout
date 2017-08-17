//
//  FeedCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedCell: UITableViewCell {
    
    var status: Status!
    var users: Users!
    var availableRef: DatabaseReference!

    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var joinBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(status: Status) {
        self.status = status
        
        self.statusLbl.text = status.content
        
        if status.available == false {
            joinBtnOutlet.isEnabled = false
        } else {
            joinBtnOutlet.isEnabled = true
        }
        

    }
    
}
