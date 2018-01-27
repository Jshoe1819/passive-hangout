//
//  ProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/10/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
import Kingfisher

class ProfileVC: UIViewController{
    
    var statusArr = [Status]()
    var selectedStatus: Status!
    var originController = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var lastStatusLbl: UILabel!
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var numberJoinedLbl: UILabel!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var profileNewFriendIndicator: UIView!
    @IBOutlet weak var pastStatusesIndicator: UIView!
    @IBOutlet weak var opaqueBackground: UIButton!
    @IBOutlet weak var signOutView: RoundedPopUp!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    @IBOutlet weak var profileOptionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child("\(currentUser)").observe(.value, with: { (snapshot) in

                if let currentUserData = snapshot.value as? Dictionary<String, Any> {
                    let user = Users(usersKey: currentUser, usersData: currentUserData)
                    self.nameLbl.text = user.name
                    self.populateProfilePicture(user: user)
                    self.populateCoverPicture(user: user)
                    let answer = user.friendsList.values.contains { (value) -> Bool in
                        value as? String == "received"
                    }
                    if answer && user.friendsList["seen"] as? String == "false" {
                        self.footerNewFriendIndicator.isHidden = false
                        self.profileNewFriendIndicator.isHidden = false
                    }
                    if user.joinedList["seen"] as? String == "false" {
                        self.pastStatusesIndicator.isHidden = false
                    }
                    self.footerNewMsgIndicator.isHidden = !user.hasNewMsg
                }
            })
        }
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.insert(status, at: 0)
                        for _ in self.statusArr {
                            for index in 0..<self.statusArr.count {
                                if self.statusArr[index].userId == Auth.auth().currentUser?.uid {
                                    self.lastStatusLbl.text = self.statusArr[index].content
                                    self.statusAgeLbl.text = self.configureTimeAgo(unixTimestamp: self.statusArr[index].postedDate)
                                    self.numberJoinedLbl.text = ("\(self.statusArr[index].joinedList.count - 1) Joined")
                                    self.selectedStatus = self.statusArr[index]
                                    break
                                }
                            }
                        }
                        
                    }
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if originController == "activityFeedToProfile" || originController == "joinedListToMyProfile" || originController == "searchToMyProfile"{
            scrollView.frame.origin.x += 500
            scrollView.isHidden = false
            
            UIView.animate(withDuration: 0.25) {
                self.scrollView.frame.origin.x -= 500
            }
            
        } else if originController == "messagesToMyProfile" || originController == "conversationToMyProfile" {
            scrollView.isHidden = false
            return

        } else if originController == "pastStatusesToMyProfile" || originController == "leaveFeedbackToMyProfile" || originController == "friendsListToMyProfile" || originController == "viewProfileToMyProfile" || originController == "mutedConvosToMyProfile" {
            scrollView.frame.origin.x -= 500
            scrollView.isHidden = false
            
            UIView.animate(withDuration: 0.25) {
                self.scrollView.frame.origin.x += 500
            }
            
        } else if originController == "editProfileToMyProfile" {
            scrollView.isHidden = false
            profileOptionsView.frame.origin.x -= 500
            
            UIView.animate(withDuration: 0.25) {
                self.profileOptionsView.frame.origin.x += 500
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
    
    func populateProfilePicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                self.profileImg.image = image
            } else {
                if user.id != "a" {
                    let profileUrl = URL(string: user.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profileImg.image = profileImage
                        ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //Handle pic download error?
                        } else {
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profileImg.image = profileImage
                                    ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func populateCoverPicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.cover["source"] as! String, options: nil) { (coverImage, cacheType) in
            if let image = coverImage {
                self.coverImg.image = image
            } else {
                if user.id != "a" {
                    let coverUrl = URL(string: user.cover["source"] as! String)
                    let data = try? Data(contentsOf: coverUrl!)
                    if let coverImage = UIImage(data: data!) {
                        self.coverImg.image = coverImage
                        ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                    }
                    
                } else {
                    let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
                    coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //Handle pic download error?
                        } else {
                            if let imageData = data {
                                if let coverImage = UIImage(data: imageData) {
                                    self.coverImg.image = coverImage
                                    ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                                }
                            }
                        }
                    })
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myProfileToPastStatuses" {
            if let nextVC = segue.destination as? PastStatusesVC {
                nextVC.originController = "myProfileToPastStatuses"
            }
        } else if segue.identifier == "myProfileToJoinedFriends" {
            if let nextVC = segue.destination as? JoinedFriendsVC {
                nextVC.selectedStatus = sender as? Status
                nextVC.originController = "myProfileToJoinedFriends"
            }
        } else if segue.identifier == "myProfileToLeaveFeedback" {
            if let nextVC = segue.destination as? LeaveFeedbackVC {
                nextVC.showMsgFooter = !footerNewMsgIndicator.isHidden
                nextVC.showProfileFooter = !footerNewFriendIndicator.isHidden
            }
        } else if segue.identifier == "profileToActivityFeed" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "profileToActivityFeed"
            }
        } else if segue.identifier == "myProfileToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "myProfileToJoinedList"
            }
        } else if segue.identifier == "myProfileToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "myProfileToSearch"
            }
        }
        
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "profileToActivityFeed", sender: nil)
    }
    
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToJoinedList", sender: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToSearch", sender: nil)
    }
    
    @IBAction func donateBtnPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.paypal.me/jshoe1819") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func editProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToEditProfile", sender: nil)
    }
    
    @IBAction func friendsListBtnPressed(_ sender: Any) {
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues(["seen": "true"])
            performSegue(withIdentifier: "myProfileToFriendsList", sender: nil)
        }
    }
    
    @IBAction func pastStatusesBtnPressed(_ sender: Any) {
        if let currentUser = Auth.auth().currentUser?.uid {
        DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues(["seen": "true"])
        performSegue(withIdentifier: "myProfileToPastStatuses", sender: nil)
        }
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        opaqueBackground.isHidden = false
        signOutView.frame.origin.y += 1000
        signOutView.isHidden = false
        
        UIView.animate(withDuration: 0.25) {
            self.signOutView.frame.origin.y -= 1000
        }
    }
    
    @IBAction func mutedConversationsBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToMutedConversations", sender: nil)
    }
    
    @IBAction func cancelSignOutBtnPressed(_ sender: Any) {
        opaqueBackground.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.signOutView.frame.origin.y += 1000
        }
        
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.signOutView.isHidden = true
            self.signOutView.frame.origin.y -= 1000
        }
        
    }
    
    @IBAction func finalSignOutBtnPressed(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        self.performSegue(withIdentifier: "myProfileToLogin", sender: nil)
    }
    
    @IBAction func leaveFeedbackBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToLeaveFeedback", sender: nil)
    }
    
}
