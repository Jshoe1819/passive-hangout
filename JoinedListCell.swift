//
//  JoinedListCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/30/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Kingfisher

class JoinedListCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var alreadyJoinedBtn: UIButton!
    
    weak var cellDelegate: JoinedListCellDelegate?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(status: Status, users: [Users]) {
        
        profilePicImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        contentLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentTapped(_:))))
        
        contentLbl.text = status.content
        statusAgeLbl.text = configureTimeAgo(unixTimestamp: status.postedDate)
        
        for index in 0..<users.count {
            if status.userId == users[index].usersKey {
                nameLbl.text = users[index].name
                populateProfPic(user: users[index])
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
            dateFormatter.timeZone = TimeZone.current //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MM/dd/yyyy" //Specify your format that you want
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
    


//        if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
//            profilePicImg.image = image
//            //print("JAKE: caching working")
//        } else {
//            if user.id != "a" {
//                //print("JAKE: image downloaded from storage")
//                let profileUrl = URL(string: user.profilePicUrl)
//                let data = try? Data(contentsOf: profileUrl!)
//                if let profileImage = UIImage(data: data!) {
//                    self.profilePicImg.image = profileImage
//                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
//                }
//                
//            } else {
//                let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
//                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        //print("JAKE: unable to download image from storage")
//                    } else {
//                        //print("JAKE: image downloaded from storage")
//                        if let imageData = data {
//                            if let profileImage = UIImage(data: imageData) {
//                                self.profilePicImg.image = profileImage
//                                ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//        }
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.didPressProfilePic(self.tag)
    }
    
    func contentTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.didPressStatusContentLbl(self.tag)
    }

    @IBAction func joinBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressJoinBtn(self.tag)
            joinBtn.isHidden = true
            alreadyJoinedBtn.isHidden = false
    }
    
    @IBAction func alreadyJoinedBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressAlreadyJoinedBtn(self.tag)
        joinBtn.isHidden = false
        alreadyJoinedBtn.isHidden = true
    }
    
    
}
