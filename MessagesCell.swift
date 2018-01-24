//
//  MessagesCell.swift
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

class MessagesCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageAgeLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var newMessageView: UIView!
    
    func configureCell(conversation: [Conversation], users: Users) {
        
        newMessageView.isHidden = true
        
        for index in 0..<conversation.count {

            if let currentUser = Auth.auth().currentUser?.uid {
                let containsUser = conversation[index].users.keys.contains(users.usersKey) && users.usersKey != currentUser
                if containsUser {

                    self.nameLbl.text = users.name
                    if let lastMsgDate = conversation[index].details["lastMsgDate"] as? Double {
                        self.messageAgeLbl.text = configureTimeAgo(unixTimestamp: lastMsgDate)
                    }
                    if let lastMsgContent = conversation[index].details["lastMsgContent"] as? String {
                        self.lastMessageLbl.text = lastMsgContent
                    }
                    if let read = conversation[index].messages["\(currentUser)"] as? Bool {
                        if !read {
                            newMessageView.isHidden = false
                            self.lastMessageLbl.font = UIFont(name: "AvenirNext-Medium", size: 14)
                        }
                    }
                    
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
    
}
