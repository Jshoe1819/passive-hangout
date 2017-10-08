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
        // Initialization code
    }
    
    func configureCell(users: Users, currentUser: Users) {
        //profilePic.image = ...
        
        ImageCache.default.retrieveImage(forKey: users.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.profilePicImg.image = image
            } else {
                print("not in cache")
                if users.id != "a" {
                    let profileUrl = URL(string: users.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePicImg.image = profileImage
                        //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                        ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
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
                                    self.profilePicImg.image = profileImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    


//        if let image = ActivityFeedVC.imageCache.object(forKey: users.profilePicUrl as NSString) {
//            profilePicImg.image = image
//            //print("JAKE: caching working")
//        } else {
//            if users.id != "a" {
//                let profileUrl = URL(string: users.profilePicUrl)
//                let data = try? Data(contentsOf: profileUrl!)
//                if let profileImage = UIImage(data: data!) {
//                    self.profilePicImg.image = profileImage
//                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: users.profilePicUrl as NSString)
//                }
//                
//            } else {
//                let profPicRef = Storage.storage().reference(forURL: users.profilePicUrl)
//                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        //print("JAKE: unable to download image from storage")
//                    } else {
//                        //print("JAKE: image downloaded from storage")
//                        if let imageData = data {
//                            if let profileImage = UIImage(data: imageData) {
//                                self.profilePicImg.image = profileImage
//                                ActivityFeedVC.imageCache.setObject(profileImage, forKey: users.profilePicUrl as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//        }
        
        if let friendKey = currentUser.friendsList[users.usersKey] as? String {
            if friendKey == "friends" {
                primaryLbl.text = users.currentCity
                nameLbl.text = users.name
                
            } else if friendKey == "sent" {
                
                //secondaryLbl.isHidden = true
                //separatorDotView.isHidden = true
                
                primaryLbl.text = users.currentCity
                //primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                nameLbl.text = users.name
                
                
            } else if friendKey == "received" {
                
                primaryLbl.text = users.currentCity
                //primaryLbl.font = UIFont(name: "AvenirNext-UltralightItalic", size: 14)
                //secondaryLbl.text = users.employer
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
