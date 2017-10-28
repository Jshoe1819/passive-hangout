//
//  ConversationCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ConversationCell: UITableViewCell {

    @IBOutlet weak var senderMsgLbl: UILabel!
    @IBOutlet weak var sentMsgAgeLbl: UILabel!
    @IBOutlet weak var receiverMsgLbl: UILabel!
    @IBOutlet weak var receivedMsgAgeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
