//
//  ViewProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Kingfisher

class ViewProfileVC: UIViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var lastStatusLbl: UILabel!
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var privateImg: UIImageView!
    @IBOutlet weak var staticStackView: UIStackView!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var occupationLbl: UILabel!
    @IBOutlet weak var employerLbl: UILabel!
    @IBOutlet weak var currentCityLbl: UILabel!
    @IBOutlet weak var schoolLbl: UILabel!
    @IBOutlet weak var seePastStatusesBtn: RoundedButton!
    @IBOutlet weak var sendMessageBtn: RoundedButton!
    @IBOutlet weak var removeFriendBtn: RoundedButton!
    @IBOutlet weak var publicAddFriendBtn: RoundedButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var privateAddFriendBtn: RoundedButton!
    @IBOutlet weak var isPrivateStackView: UIStackView!
    @IBOutlet weak var footerNewFriendNotification: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    var selectedProfile: Users!
    var statusArr = [Status]()
    var selectedStatusArr = [Status]()
    var selectedStatus: Status!
    var originController = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if originController == "feedToViewProfile" || originController == "joinedListToViewProfile" {
            self.backBtn.isHidden = true
        }
        
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.insert(status, at: 0)
                        
                        for _ in self.statusArr {
                            for index in 0..<self.statusArr.count {
                                if self.statusArr[index].userId == self.selectedProfile.usersKey {
                                    self.lastStatusLbl.text = self.statusArr[index].content
                                    self.statusAgeLbl.text = self.configureTimeAgo(unixTimestamp: self.statusArr[index].postedDate)
                                    break
                                }
                            }
                        }
                        
                    }
                }
            }
            self.currentUserStatusArr(array: self.statusArr)
        })
        
        currentUserStatusArr(array: statusArr)
        
        nameLbl.text = selectedProfile.name
        populateCoverPicture(user: selectedProfile)
        populateProfilePicture(user: selectedProfile)
        
        //for now friend status is from perspective of selected profile NOT current user
        //call function for readability
        if let currentUser = Auth.auth().currentUser?.uid {
            if let friendStatus = selectedProfile.friendsList[currentUser] as? String {
                if friendStatus == "received" {
                    if selectedProfile.isPrivate {
                        privateConfigure()
                        privateAddFriendBtn.setTitle("Friend Request Sent", for: .normal)
                        
                    } else if !selectedProfile.isPrivate {
                        publicConfigure()
                        publicAddFriendBtn.setTitle("Friend Request Sent", for: .normal)
                        
                    }
                    
                } else if friendStatus == "sent" {
                    if selectedProfile.isPrivate {
                        privateConfigure()
                        privateAddFriendBtn.setTitle("Respond to Friend Request", for: .normal)
                        
                    } else if !selectedProfile.isPrivate {
                        publicConfigure()
                        publicAddFriendBtn.setTitle("Respond to Friend Request", for: .normal)
                        
                    }
                    
                } else if friendStatus == "friends" {
                    publicConfigure()
                    removeFriendBtn.isHidden = false
                    publicAddFriendBtn.isHidden = true
                    
                }
                
            } else {
                if selectedProfile.isPrivate {
                    privateConfigure()
                    publicAddFriendBtn.setTitle("Add Friend", for: .normal)
                } else if !selectedProfile.isPrivate {
                    publicConfigure()
                    removeFriendBtn.isHidden = true
                    publicAddFriendBtn.isHidden = false
                    publicAddFriendBtn.setTitle("Add Friend", for: .normal)
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func privateConfigure() {
        
        scrollView.isScrollEnabled = false
        privateImg.isHidden = false
        lastStatusLbl.isHidden = true
        statusAgeLbl.isHidden = true
        staticStackView.isHidden = true
        userInfoStackView.isHidden = true
        seePastStatusesBtn.isHidden = true
        sendMessageBtn.isHidden = true
        removeFriendBtn.isHidden = true
        publicAddFriendBtn.isHidden = true
        privateAddFriendBtn.isHidden = false
        isPrivateStackView.isHidden = false
        
    }
    
    func publicConfigure() {
        
        occupationLbl.text = emptyCheck(inputString: selectedProfile.occupation)
        employerLbl.text = emptyCheck(inputString: selectedProfile.employer)
        currentCityLbl.text = emptyCheck(inputString: selectedProfile.currentCity)
        schoolLbl.text = emptyCheck(inputString: selectedProfile.school)
        isPrivateStackView.isHidden = true
        
    }
    
    func emptyCheck(inputString: String) -> String {
        if inputString == "" {
            return "N/A"
        } else {
            return inputString
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
    
    func populateProfilePicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.profileImg.image = image
            } else {
                print("not in cache")
                if user.id != "a" {
                    let profileUrl = URL(string: user.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profileImg.image = profileImage
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
                                    self.profileImg.image = profileImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    


        //print("JAKE: going in to else")
//        if user.id != "a" {
//            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
//                profileImg.image = image
//                //print("JAKE: Cache working")
//            } else {
//                let profileUrl = URL(string: user.profilePicUrl)
//                let data = try? Data(contentsOf: profileUrl!)
//                if let profileImage = UIImage(data: data!) {
//                    self.profileImg.image = profileImage
//                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
//                }
//            }
//            
//        } else {
//            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
//                profileImg.image = image
//                //print("JAKE: Cache working")
//            } else {
//                let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
//                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        //print("JAKE: unable to download image from storage")
//                    } else {
//                        //print("JAKE: image downloaded from storage")
//                        if let imageData = data {
//                            if let image = UIImage(data: imageData) {
//                                self.profileImg.image = image
//                                ActivityFeedVC.imageCache.setObject(image, forKey: user.profilePicUrl as NSString)
//                                //self.postImg.image = image
//                                //FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//            
//        }
    }
    
    func populateCoverPicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.cover["source"] as! String, options: nil) { (coverImage, cacheType) in
            if let image = coverImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.coverImg.image = image
            } else {
                //print("not in cache")
                if user.id != "a" {
                    let coverUrl = URL(string: user.cover["source"] as! String)
                    let data = try? Data(contentsOf: coverUrl!)
                    if let coverImage = UIImage(data: data!) {
                        self.coverImg.image = coverImage
                        //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                        ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                    }
                    
                } else {
                    let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
                    coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //print("JAKE: unable to download image from storage")
                        } else {
                            //print("JAKE: image downloaded from storage")
                            if let imageData = data {
                                if let coverImage = UIImage(data: imageData) {
                                    self.coverImg.image = coverImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                                }
                            }
                        }
                    })
                }
            }
        }
    


//        if user.id != "a" {
//
//            if let coverStorageUrl = user.cover["source"] as? String {
//
//                if let image = ActivityFeedVC.imageCache.object(forKey: coverStorageUrl as NSString) {
//                    //print("using cache")
//                    coverImg.image = image
//                }
//                else {
//                    //print("downloading")
//                    let coverUrl = URL(string: user.cover["source"] as! String)
//                    let data = try? Data(contentsOf: coverUrl!)
//                    if let coverImage = UIImage(data: data!) {
//                        self.coverImg.image = coverImage
//                        ActivityFeedVC.imageCache.setObject(coverImage, forKey: coverStorageUrl as NSString)
//                    }
//                }
//            }
//            
//        } else {
//            if let coverStorageUrl = user.cover["source"] as? String {
//                
//                if let image = ActivityFeedVC.imageCache.object(forKey: coverStorageUrl as NSString) {
//                    //print("using cache")
//                    coverImg.image = image
//                } else {
//                    //print("downloading")
//                    let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
//                    coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                        if error != nil {
//                            //print("JAKE: unable to download image from storage")
//                        } else {
//                            //print("JAKE: image downloaded from storage")
//                            if let imageData = data {
//                                if let image = UIImage(data: imageData) {
//                                    self.coverImg.image = image
//                                    ActivityFeedVC.imageCache.setObject(image, forKey: coverStorageUrl as NSString)
//                                    
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//        }
    }
    
    func currentUserStatusArr(array: [Status]) {
        for status in array {
            if status.userId == selectedProfile.usersKey {
                selectedStatusArr.append(status)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if let currentUser = Auth.auth().currentUser?.uid {
        //            let currentProfile = usersArr
        //        }
        
        if segue.identifier == "viewProfileToPastStatuses" {
            if let nextVC = segue.destination as? PastStatusesVC {
                nextVC.selectedUserStatuses = sender as! [Status]
                if originController == "feedToViewProfile" {
                    nextVC.originController = "feedToViewProfile"
                } else if originController == "joinedFriendsToViewProfile" {
                    nextVC.originController = "joinedFriendsToViewProfile"
                    nextVC.selectedStatus = selectedStatus
                } else {
                    nextVC.originController = "viewProfileToPastStatuses"
                }
                nextVC.viewedProfile = selectedProfile
            }
        }
        if segue.identifier == "viewProfileToJoinedFriends" {
            if let nextVC = segue.destination as? JoinedFriendsVC {
                nextVC.selectedUser = selectedProfile
                nextVC.selectedStatus = selectedStatus
            }
        }
    }
    
    @IBAction func seePastStatusesBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToPastStatuses", sender: selectedStatusArr)
    }
    @IBAction func sendMessageBtnPressed(_ sender: Any) {
    }
    @IBAction func removeFriendBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Remove Friend", message: "Are you sure you would like to remove this friend from your list?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.destructive, handler: { action in
            let friendKey = self.selectedProfile.usersKey
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
                self.performSegue(withIdentifier: "viewProfileToFriendsList", sender: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func publicAddFriendBtnPressed(_ sender: Any) {
        
        if publicAddFriendBtn.title(for: .normal) == "Respond to Friend Request" {
            performSegue(withIdentifier: "viewProfileToFriendsList", sender: nil)
            
        } else if publicAddFriendBtn.title(for: .normal) == "Friend Request Sent" {
            
            let friendKey = selectedProfile.usersKey
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
            }
            publicAddFriendBtn.setTitle("Add Friend", for: .normal)
            
        } else {
            
            let friendKey = selectedProfile.usersKey
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues([friendKey: "sent"])
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUser: "received"])
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues(["seen": "false"])
            }
            publicAddFriendBtn.setTitle("Friend Request Sent", for: .normal)
        }
    }
    
    @IBAction func privateAddFriendBtnPressed(_ sender: Any) {
        
        if privateAddFriendBtn.title(for: .normal) == "Respond to Friend Request" {
            performSegue(withIdentifier: "viewProfileToFriendsList", sender: nil)
            
        } else if privateAddFriendBtn.title(for: .normal) == "Friend Request Sent" {
            
            let friendKey = selectedProfile.usersKey
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
            }
            privateAddFriendBtn.setTitle("Add Friend", for: .normal)
            
        } else {
            
            let friendKey = selectedProfile.usersKey
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues([friendKey: "sent"])
                DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUser: "received"])
            }
            privateAddFriendBtn.setTitle("Friend Request Sent", for: .normal)
        }
        
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        //performSegue(withIdentifier: "feedToViewProfile", sender: nil)
        if originController == "feedToViewProfile" {
            performSegue(withIdentifier: "viewProfileToFeed", sender: nil)
        } else if
            originController == "joinedFriendsToViewProfile" {
                performSegue(withIdentifier: "viewProfileToJoinedFriends", sender: nil)
            }
        
            //        else if originController == "joinedListToViewProfile" {
            //            performSegue(withIdentifier: "viewProfileToJoinedList", sender: nil)
            //        }
        else {
            performSegue(withIdentifier: "viewProfileToFriendsList", sender: nil)
        }
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToHome", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToJoinedList", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToMyProfile", sender: nil)
    }
    
}
