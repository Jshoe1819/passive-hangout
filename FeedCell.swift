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
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import Kingfisher

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var joinBtnOutlet: UIButton!
    @IBOutlet weak var alreadyJoinedBtn: UIButton!
    
    weak var cellDelegate: FeedCellDelegate?
    
    func configureCell(status: Status, users: [Users]) {
        
        profilePicImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        
        for index in 0..<users.count {
            if status.userId == users[index].usersKey {
                self.displayNameLbl.text = users[index].name
                self.cityLbl.text = status.city.localizedCapitalized
                self.statusLbl.text = status.content
                self.statusAgeLbl.text = configureTimeAgo(unixTimestamp: status.postedDate)
                
                ImageCache.default.retrieveImage(forKey: users[index].profilePicUrl, options: nil) { (profileImage, cacheType) in
                    if let image = profileImage {
                        self.profilePicImg.image = image
                    } else {
                        if users[index].id != "a" {
                            let profileUrl = URL(string: users[index].profilePicUrl)
                            let data = try? Data(contentsOf: profileUrl!)
                            if let profileImage = UIImage(data: data!) {
                                self.profilePicImg.image = profileImage
                                ImageCache.default.store(profileImage, forKey: users[index].profilePicUrl)
                            }
                            
                        } else {
                            let profPicRef = Storage.storage().reference(forURL: users[index].profilePicUrl)
                            profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    //Handle error?
                                } else {
                                    if let imageData = data {
                                        if let profileImage = UIImage(data: imageData) {
                                            self.profilePicImg.image = profileImage
                                            ImageCache.default.store(profileImage, forKey: users[index].profilePicUrl)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
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
        } else if (daysInterval >= 1 && daysInterval < 15) {
            if daysInterval == 1 {
                return ("\(daysInterval) day ago")
            } else {
                return("\(daysInterval) days ago")
            }
        } else if daysInterval >= 15 {
            
            let shortenedUnix = unixTimestamp / 1000
            let date = Date(timeIntervalSince1970: shortenedUnix)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var strDate = dateFormatter.string(from: date)
            if strDate.characters.first == "0" {
                strDate.characters.removeFirst()
                return strDate
            }
            return strDate
            
        } else {
            return ("a few seconds ago")
        }
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.didPressProfilePic(self.tag)
    }
    
    @IBAction func joinBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressJoinBtn(self.tag)
        joinBtnOutlet.isHidden = true
        alreadyJoinedBtn.isHidden = false
    }
    
    @IBAction func alreadyJoinedBtnPressed(_ sender: Any) {
        cellDelegate?.didPressAlreadyJoinedBtn(self.tag)
        joinBtnOutlet.isHidden = false
        alreadyJoinedBtn.isHidden = true
    }
}
