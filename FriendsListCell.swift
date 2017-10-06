//
//  FriendsListCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/27/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseStorage

class FriendsListCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    weak var cellDelegate: FriendsListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(friendsList: Dictionary<String, Any>, users: Users) {
        //profilePic.image = ...
        
        if let image = ActivityFeedVC.imageCache.object(forKey: users.profilePicUrl as NSString) {
            profilePic.image = image
            //print("JAKE: caching working")
        } else {
            if users.id != "a" {
                let profileUrl = URL(string: users.profilePicUrl)
                let data = try? Data(contentsOf: profileUrl!)
                if let profileImage = UIImage(data: data!) {
                    self.profilePic.image = profileImage
                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: users.profilePicUrl as NSString)
                }
                
            } else {
                let profPicRef = Storage.storage().reference(forURL: users.profilePicUrl)
                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        //print("JAKE: unable to download image from storage")
                    } else {
                        //print("JAKE: image downloaded from storage")
                        if let imageData = data {
                            if let profileImage = UIImage(data: imageData) {
                                self.profilePic.image = profileImage
                                ActivityFeedVC.imageCache.setObject(profileImage, forKey: users.profilePicUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
        
        if let friendKey = friendsList[users.usersKey] as? String {
            if friendKey == "friends" {
                
                menuBtn.isHidden = false
                approveBtn.isHidden = true
                ignoreBtn.isHidden = true
                
                primaryLbl.text = users.currentCity
                //secondaryLbl.text = users.employer
                nameLbl.text = users.name
                
            } else if friendKey == "sent" {
                
                menuBtn.isHidden = true
                //secondaryLbl.isHidden = true
                //separatorDotView.isHidden = true
                
                primaryLbl.text = "Friend Request Sent"
                primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                nameLbl.text = users.name
                
            } else if friendKey == "received" {
                
                menuBtn.isHidden = true
                ignoreBtn.isHidden = false
                approveBtn.isHidden = false
                
                primaryLbl.text = "Awaiting Approval"
                primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                //secondaryLbl.text = users.employer
                nameLbl.text = users.name
                
            } else {
                
                menuBtn.isHidden = true
                //secondaryLbl.isHidden = true
                //separatorDotView.isHidden = true
                
            }
        }
        
    }
    @IBAction func ignoreBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressIgnoreBtn(self.tag)
    }
    @IBAction func approveBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressAcceptBtn(self.tag)
    }
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressMenuBtn(self.tag)
    }
    
    


}
