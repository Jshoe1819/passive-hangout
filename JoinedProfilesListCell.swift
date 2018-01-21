//
//  JoinedProfilesListCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/7/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher

class JoinedProfilesListCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var requestSentBtn: UIButton!
    
    weak var cellDelegate: JoinedProfilesListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addFriendBtn.layer.cornerRadius = 8
        addFriendBtn.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        addFriendBtn.layer.borderWidth = 1
        
        requestSentBtn.layer.cornerRadius = 8
        requestSentBtn.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        requestSentBtn.layer.borderWidth = 1
        
    }
    
    func configureCell(users: Users, currentUser: Users) {
        
        addFriendBtn.isHidden = true
        requestSentBtn.isHidden = true
        
        ImageCache.default.retrieveImage(forKey: users.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                self.profilePicImg.image = image
            } else {
                if users.id != "a" {
                    let profileUrl = URL(string: users.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePicImg.image = profileImage
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
                                    self.profilePicImg.image = profileImage
                                    ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
        
        if let friendKey = currentUser.friendsList[users.usersKey] as? String {
            if friendKey == "friends" {
                primaryLbl.text = users.currentCity
                nameLbl.text = users.name
            } else if friendKey == "sent" {
                requestSentBtn.isHidden = false
                primaryLbl.text = users.currentCity
                nameLbl.text = users.name
            } else if friendKey == "received" {
                primaryLbl.text = users.currentCity
                nameLbl.text = users.name
            }
        } else {
            primaryLbl.text = users.currentCity
            addFriendBtn.isHidden = false
            nameLbl.text = users.name
        }
    }
    
    @IBAction func addFriendBtnPressed(_ sender: Any) {
        cellDelegate?.didPressAddFriendBtn(self.tag)
        addFriendBtn.isHidden = true
        requestSentBtn.isHidden = false
    }
    
    @IBAction func requestSentBtnPressed(_ sender: Any) {
        cellDelegate?.didPressRequestSentBtn(self.tag)
        addFriendBtn.isHidden = false
        requestSentBtn.isHidden = true
    }
    
}
