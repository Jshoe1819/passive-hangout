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
import FBSDKLoginKit
import FBSDKCoreKit

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
                    self.statusAgeLbl.text = configureTimeAgo(unixTimestamp: status.postedDate)
                    
                    if let image = ActivityFeedVC.imageCache.object(forKey: users[index].profilePicUrl as NSString) {
                        profilePicImg.image = image
                        //print("JAKE: caching working")
                    } else {
                        if users[index].id != "a" {
                            let profileUrl = URL(string: users[index].profilePicUrl)
                            let data = try? Data(contentsOf: profileUrl!)
                            if let profileImage = UIImage(data: data!) {
                                self.profilePicImg.image = profileImage
                                ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                            }
                            
                        } else {
                            let profPicRef = Storage.storage().reference(forURL: users[index].profilePicUrl)
                            profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    //print("JAKE: unable to download image from storage")
                                } else {
                                    //print("JAKE: image downloaded from storage")
                                    if let imageData = data {
                                        if let profileImage = UIImage(data: imageData) {
                                            self.profilePicImg.image = profileImage
                                            ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                        }
                                    }
                                }
                            })
                        }
                    }
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
    
    func configureTimeAgo(unixTimestamp: Double) -> String {
        let date = Date().timeIntervalSince1970
        let secondsInterval = Int((date - unixTimestamp/1000).rounded().nextDown)
        let minutesInterval = secondsInterval / 60
        let hoursInterval = minutesInterval / 60
        let daysInterval = hoursInterval / 24
        
        if (secondsInterval >= 15 && secondsInterval < 60) {
            return("\(secondsInterval) seconds ago")
        } else if (minutesInterval >= 1 && minutesInterval < 60) {
            if minutesInterval == 1 {
                return ("\(minutesInterval) minute ago")
            } else {
                return("\(minutesInterval) minutes ago")
            }
        } else if (hoursInterval >= 1 && hoursInterval < 24) {
            if hoursInterval == 1 {
                return ("\(hoursInterval) hour ago")
            } else {
                return("\(hoursInterval) hours ago")
            }
        } else if (daysInterval >= 1) {
            if daysInterval == 1 {
                return ("\(daysInterval) day ago")
            } else {
                return("\(daysInterval) days ago")
            }
        } else {
            return ("a few seconds ago")
        }
    }
}
