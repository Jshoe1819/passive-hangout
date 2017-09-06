//
//  FeedCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class FeedCell: UITableViewCell {
    
    var status: Status!
    var users: Users!
    var availableRef: DatabaseReference!
    
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var joinBtnOutlet: UIButton!
    @IBOutlet weak var statusAgeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(status: Status, users: [Users]) {
        self.status = status
        
        for index in 0..<users.count {
            for key in users[index].statusId.keys {
                if key == status.statusKey {
                    self.displayNameLbl.text = users[index].name
                    
                    let profPicRef = Storage.storage().reference(forURL: users[index].profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //print("JAKE: unable to download image from storage")
                        } else {
                            //print("JAKE: image downloaded from storage")
                            if let imageData = data {
                                if let image = UIImage(data: imageData) {
                                    self.profilePicImg.image = image
                                    //self.postImg.image = image
                                    //FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                                }
                            }
                        }
                    })
                    
                }
            }
        }
        
        
        self.statusLbl.text = status.content
        
        if status.available == false {
            joinBtnOutlet.isEnabled = false
        } else {
            joinBtnOutlet.isEnabled = true
        }
        
        
    }
    
}
