//
//  FriendsListCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/27/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher

class FriendsListCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    
    weak var cellDelegate: FriendsListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        approveBtn.layer.cornerRadius = 8
        approveBtn.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        ignoreBtn.layer.cornerRadius = 8
    }
    
    func configureCell(friendsList: Dictionary<String, Any>, users: Users) {
        
        approveBtn.isHidden = true
        ignoreBtn.isHidden = true
        
        ImageCache.default.retrieveImage(forKey: users.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                self.profilePic.image = image
            } else {
                if users.id != "a" {
                    let profileUrl = URL(string: users.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePic.image = profileImage
                        ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: users.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //Handle error?
                        } else {
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profilePic.image = profileImage
                                    ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
        
        if let friendKey = friendsList[users.usersKey] as? String {
            if friendKey == "friends" {
                
                approveBtn.isHidden = true
                ignoreBtn.isHidden = true
                
                primaryLbl.text = users.currentCity
                nameLbl.text = users.name
                
            } else if friendKey == "sent" {
                
                primaryLbl.text = "Friend Request Sent"
                primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                nameLbl.text = users.name
                
            } else if friendKey == "received" {
                
                ignoreBtn.isHidden = false
                approveBtn.isHidden = false
                
                primaryLbl.text = "Awaiting Approval"
                primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                nameLbl.text = users.name
                
            }
        }
        
    }
    
    @IBAction func ignoreBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressIgnoreBtn(self.tag)
    }
    
    @IBAction func approveBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressAcceptBtn(self.tag)
    }
    
}
