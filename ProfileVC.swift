//
//  ProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/10/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase

class ProfileVC: UIViewController{
    
    var statusArr = [Status]()

    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var lastStatusLbl: UILabel!
    @IBOutlet weak var statusAgeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child("\(currentUser)").observe(.value, with: { (snapshot) in
                //print("USERS: \(snapshot)")
                if let currentUserData = snapshot.value as? Dictionary<String, Any> {
                    let user = Users(usersKey: currentUser, usersData: currentUserData)
                    self.populateProfilePicture(user: user)
                    //print(user.cover["source"])
                    self.populateCoverPicture(user: user)
                }
            })
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
                                if self.statusArr[index].userId == Auth.auth().currentUser?.uid {
                                    self.lastStatusLbl.text = self.statusArr[index].content
                                    self.statusAgeLbl.text = self.configureTimeAgo(unixTimestamp: self.statusArr[index].postedDate)
                                    break
                                }
                            }
                        }
                        
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func populateProfilePicture(user: Users) {
        
        //print("JAKE: going in to else")
        if user.id != "a" {
            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
                profileImg.image = image
                //print("JAKE: Cache working")
            } else {
                let profileUrl = URL(string: user.profilePicUrl)
                let data = try? Data(contentsOf: profileUrl!)
                if let profileImage = UIImage(data: data!) {
                    self.profileImg.image = profileImage
                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
                }
            }
            
        } else {
            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
                profileImg.image = image
                //print("JAKE: Cache working")
            } else {
                let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        //print("JAKE: unable to download image from storage")
                    } else {
                        //print("JAKE: image downloaded from storage")
                        if let imageData = data {
                            if let image = UIImage(data: imageData) {
                                self.profileImg.image = image
                                ActivityFeedVC.imageCache.setObject(image, forKey: user.profilePicUrl as NSString)
                                //self.postImg.image = image
                                //FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }
            
        }
    }
    
    func populateCoverPicture(user: Users) {
        
        if user.id != "a" {
            let coverUrl = URL(string: user.cover["source"] as! String)
            let data = try? Data(contentsOf: coverUrl!)
            if let coverImage = UIImage(data: data!) {
                self.coverImg.image = coverImage
            }
            
        } else {
            let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
            coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    //print("JAKE: unable to download image from storage")
                } else {
                    //print("JAKE: image downloaded from storage")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.coverImg.image = image
                            //self.postImg.image = image
                            //FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
            
        }
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "profileToActivityFeed", sender: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    
    @IBAction func editProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToEditProfile", sender: nil)
    }
    
    @IBAction func friendsListBtnPressed(_ sender: Any) {
    }
    
    @IBAction func pastStatusesBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "myProfileToPastStatuses", sender: nil)
    }
    
    @IBAction func notificationsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func leaveFeedbackBtnPressed(_ sender: Any) {
    }
    
}
