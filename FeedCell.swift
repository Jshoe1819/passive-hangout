//
//  FeedCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {
    
    var status: Status!
    var availableRef: DatabaseReference!

    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var timeElapsedLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(status: Status, profilePic: UIImage? = nil) {
        self.status = status
        //availableRef - DataService.ds.

    }
    
}
