//
//  SearchProfilesCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/9/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher
import FirebaseStorage

class SearchProfilesCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var friendsStatusLbl: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var requestSentBtn: UIButton!
    
    weak var cellDelegate: SearchProfilesDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addFriendBtn.layer.cornerRadius = 3
        addFriendBtn.layer.borderColor = UIColor.purple.cgColor
        addFriendBtn.layer.borderWidth = 1
        
        requestSentBtn.layer.cornerRadius = 3
        requestSentBtn.layer.borderColor = UIColor.purple.cgColor
        requestSentBtn.layer.borderWidth = 1
        
        // Initialization code
    }
    
    func configureCell(user: Users, currentUser: Users) {
        profilePicImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        populateProfPic(user: user)
        nameLbl.text = user.name
        //primaryLbl.text = user.currentCity
        
        let friendStatus = currentUser.friendsList.keys.contains { (key) -> Bool in
            user.usersKey == key
        }
        
        if friendStatus {
            if currentUser.friendsList[user.usersKey] as? String == "friends" {
                if user.currentCity == "" {
                    primaryLbl.text = "Friends"
                    primaryLbl.isHidden = false
                    separatorView.isHidden = true
                    friendsStatusLbl.isHidden = true
                } else {
                    primaryLbl.text = user.currentCity
                    primaryLbl.isHidden = false
                    separatorView.isHidden = false
                    friendsStatusLbl.text = "Friends"
                    friendsStatusLbl.isHidden = false
                }
            } else if currentUser.friendsList[user.usersKey] as? String == "sent" {
                if user.currentCity == "" {
                    primaryLbl.isHidden = true
                    separatorView.isHidden = true
                    friendsStatusLbl.isHidden = true
                } else {
                    primaryLbl.text = user.currentCity
                    primaryLbl.isHidden = false
                    separatorView.isHidden = true
                    friendsStatusLbl.isHidden = true
                }
                requestSentBtn.isHidden = false
            } else if currentUser.friendsList[user.usersKey] as? String == "received" {
                if user.currentCity == "" {
                    primaryLbl.text = "Received Request"
                    primaryLbl.isHidden = false
                    separatorView.isHidden = true
                    friendsStatusLbl.isHidden = true
                } else {
                    primaryLbl.text = user.currentCity
                    primaryLbl.isHidden = false
                    separatorView.isHidden = false
                    friendsStatusLbl.text = "Received Request"
                    friendsStatusLbl.isHidden = false
                }
            }
        }
        
        if !friendStatus {
            if user.currentCity == "" {
                primaryLbl.isHidden = true
                separatorView.isHidden = true
                friendsStatusLbl.isHidden = true
            } else {
                primaryLbl.text = user.currentCity
                primaryLbl.isHidden = false
                separatorView.isHidden = true
                friendsStatusLbl.isHidden = true
            }
            addFriendBtn.isHidden = false
        }
        
    }
    
    func populateProfPic(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.profilePicImg.image = image
            } else {
                print("not in cache")
                if user.id != "a" {
                    let profileUrl = URL(string: user.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePicImg.image = profileImage
                        //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                        ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //print("JAKE: unable to download image from storage")
                        } else {
                            //print("JAKE: image downloaded from storage")
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profilePicImg.image = profileImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.didPressProfilePic(self.tag)
    }
    
    @IBAction func addFriendBtnPressed(_ sender: Any) {
        cellDelegate?.didPressAddFriendBtn(self.tag)
        addFriendBtn.isHidden = true
        requestSentBtn.isHidden = false
    }
    @IBAction func requestBtnPressed(_ sender: Any) {
        cellDelegate?.didPressRequestSentBtn(self.tag)
        addFriendBtn.isHidden = false
        requestSentBtn.isHidden = true
    }
}
