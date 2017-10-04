//
//  ActivityFeedVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/12/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class ActivityFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, FeedCellDelegate {
    
    var statusArr = [Status]()
    var usersArr = [Users]()
    var placeholderLabel : UILabel!
    //let characterLimit = CHARACTER_LIMIT
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: NewStatusTextView!
    @IBOutlet weak var statusPopupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusPopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var opaqueStatusBackground: UIButton!
    @IBOutlet weak var availableSelected: UISegmentedControl!
    @IBOutlet weak var sortPopUpBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableIndicatorImg: UIImageView!
    @IBOutlet weak var nameIndicatorImg: UIImageView!
    @IBOutlet weak var lastUpdatedIndicatorImg: UIImageView!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //send url to user node, url will always be the same, only needs to happen once, move out of vc
        if FBSDKAccessToken.current() != nil {
            if let currentUser = Auth.auth().currentUser?.uid {
                let facebookId = FBSDKAccessToken.current().userID
                let profilePicUrl = "https://graph.facebook.com/\(facebookId!)/picture?type=large"
                let picUpdate = ["\(currentUser)/profilePicUrl": profilePicUrl] as Dictionary<String, Any>
                DataService.ds.REF_USERS.updateChildValues(picUpdate)
                //print("JAKE: \(profilePicUrl)")
            }
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        placeholderLabel = UILabel()
        placeholderLabel.text = EMPTY_STATUS_STRING
        placeholderLabel.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        textView.addSubview(placeholderLabel)
        //placeholderLabel.preferredMaxLayoutWidth = CGFloat(tableView.frame.width)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.lineBreakMode = .byWordWrapping
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.insert(status, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if currentUser == users.usersKey {
                                let answer = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if answer && users.friendsList["seen"] as? String == "false" {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = statusArr[indexPath.row]
        let users = usersArr
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            if let currentUser = Auth.auth().currentUser?.uid {
                let join = status.joinedList.keys.contains { (key) -> Bool in
                    key == currentUser
                }
                if join {
                    cell.joinBtnOutlet.isHidden = true
                    cell.alreadyJoinedBtn.isHidden = false
                } else{
                    cell.joinBtnOutlet.isHidden = false
                    cell.alreadyJoinedBtn.isHidden = true
                }
            }
            
            cell.cellDelegate = self
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.configureCell(status: status, users: users)
            return cell
        } else {
            return FeedCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newStatusBtn(_ sender: Any) {
        statusPopupBottomConstraint.constant = 272
        statusPopupTopConstraint.constant = 5
        opaqueStatusBackground.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textViewDidChange(self.textView)
            self.textView.becomeFirstResponder()
            self.availableSelected.selectedSegmentIndex = 0
        })
    }
    
    @IBAction func cancelNewStatus(_ sender: Any) {
        statusPopupBottomConstraint.constant = -325
        statusPopupTopConstraint.constant = 680
        sortPopUpBottomConstraint.constant = -240
        opaqueStatusBackground.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textView.resignFirstResponder()
            self.textView.text = ""
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.contains("\n") {
            return false
        }
        
        //label.text = ("/(50 - updatedText.characters.count) / 50 Characters Remaining")
        //change to number of lines restriction, label display something when out of room? or allow scrolling and keep 50?
        //resolve in performance clean up
        return updatedText.characters.count <= CHARACTER_LIMIT
    }
    
    func setAvailable(segmentControl: UISegmentedControl) -> Bool {
        if segmentControl.selectedSegmentIndex == 0 {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func saveStatusBtnPressed(_ sender: Any) {
        guard let statusContent = textView.text, statusContent != "" else {
            return
        }
        
        if let statusContent = textView.text {
            //print("JAKE: \(statusContent)")
            if let user = Auth.auth().currentUser {
                let userId = user.uid
                let key = DataService.ds.REF_BASE.child("status").childByAutoId().key
                let status = ["available": setAvailable(segmentControl: availableSelected),
                              "content": statusContent,
                              "joinedList": ["a": true],
                              "joinedNumber": 0,
                              "postedDate": ServerValue.timestamp(),
                              "userId": userId] as [String : Any]
                let childUpdates = ["/status/\(key)": status,
                                    "/users/\(userId)/statusId/\(key)/": true] as Dictionary<String, Any>
                //print("JAKE: \(childUpdates)")
                DataService.ds.REF_BASE.updateChildValues(childUpdates)
                
                statusPopupBottomConstraint.constant = -325
                statusPopupTopConstraint.constant = 680
                opaqueStatusBackground.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                    self.textView.resignFirstResponder()
                    self.textView.text = ""
                })
                
            }
        }
    }
    
    @IBAction func homeBTnPressed(_ sender: Any) {
        
        if tableView.contentOffset == CGPoint.zero {
            
            DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
                
                self.statusArr = []
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        //print("STATUS: \(snap)")
                        if let statusDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let status = Status(statusKey: key, statusData: statusDict)
                            self.statusArr.insert(status, at: 0)
                        }
                    }
                }
                self.tableView.reloadData()
            })
            
        } else {
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if let currentUser = Auth.auth().currentUser?.uid {
        //            let currentProfile = usersArr
        //        }
        
        if segue.identifier == "activityFeedToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                if let currentUser = Auth.auth().currentUser?.uid {
                    for index in 0..<usersArr.count {
                        if usersArr[index].usersKey == currentUser {
                            nextVC.statusArr = statusArr
                            nextVC.currentUser = usersArr[index]
                            nextVC.usersArr = usersArr
                        }
                    }
                }
            }
        }
        if segue.identifier == "feedToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                nextVC.originController = "feedToViewProfile"
            }
        }
    }
    
    
    @IBAction func sortBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToJoinedList", sender: self)
        //        opaqueStatusBackground.isHidden = false
        //        sortPopUpBottomConstraint.constant = 55
        //        UIView.animate(withDuration: 0.3, animations: {
        //            self.view.layoutIfNeeded()
        //        })
    }
    //
    //    @IBAction func availableSortBtnPressed(_ sender: Any) {
    //        availableIndicatorImg.isHidden = false
    //        nameIndicatorImg.isHidden = true
    //        lastUpdatedIndicatorImg.isHidden = true
    //        opaqueStatusBackground.isHidden = true
    //        sortPopUpBottomConstraint.constant = -240
    //        UIView.animate(withDuration: 0.3, animations: {
    //            self.view.layoutIfNeeded()
    //        })
    //        DataService.ds.REF_STATUS.queryOrdered(byChild: "available").observe(.value, with: { (snapshot) in
    //
    //            self.statusArr = []
    //
    //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
    //                for snap in snapshot {
    //                    //print("STATUS: \(snap)")
    //                    if let statusDict = snap.value as? Dictionary<String, Any> {
    //                        let key = snap.key
    //                        let status = Status(statusKey: key, statusData: statusDict)
    //                        self.statusArr.insert(status, at: 0)
    //                    }
    //                }
    //            }
    //            self.tableView.reloadData()
    //        })
    //    }
    //
    //    @IBAction func nameSortBtnPressed(_ sender: Any) {
    //        nameIndicatorImg.isHidden = false
    //        lastUpdatedIndicatorImg.isHidden = true
    //        availableIndicatorImg.isHidden = true
    //        opaqueStatusBackground.isHidden = true
    //        sortPopUpBottomConstraint.constant = -240
    //        UIView.animate(withDuration: 0.3, animations: {
    //            self.view.layoutIfNeeded()
    //        })
    //        DataService.ds.REF_STATUS.queryOrdered(byChild: "userId").observe(.value, with: { (snapshot) in
    //
    //            self.statusArr = []
    //
    //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
    //                for snap in snapshot {
    //                    //print("STATUS: \(snap)")
    //                    if let statusDict = snap.value as? Dictionary<String, Any> {
    //                        let key = snap.key
    //                        let status = Status(statusKey: key, statusData: statusDict)
    //                        self.statusArr.insert(status, at: 0)
    //                    }
    //                }
    //            }
    //            self.tableView.reloadData()
    //        })
    //    }
    //
    //    @IBAction func lastUpdatedSortBtnPressed(_ sender: Any) {
    //        lastUpdatedIndicatorImg.isHidden = false
    //        availableIndicatorImg.isHidden = true
    //        nameIndicatorImg.isHidden = true
    //        opaqueStatusBackground.isHidden = true
    //        sortPopUpBottomConstraint.constant = -240
    //        UIView.animate(withDuration: 0.3, animations: {
    //            self.view.layoutIfNeeded()
    //        })
    //        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
    //
    //            self.statusArr = []
    //
    //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
    //                for snap in snapshot {
    //                    //print("STATUS: \(snap)")
    //                    if let statusDict = snap.value as? Dictionary<String, Any> {
    //                        let key = snap.key
    //                        let status = Status(statusKey: key, statusData: statusDict)
    //                        self.statusArr.insert(status, at: 0)
    //                    }
    //                }
    //            }
    //            self.tableView.reloadData()
    //        })
    //    }
    //
    //    @IBAction func cancelSortBtnPressed(_ sender: Any) {
    //        opaqueStatusBackground.isHidden = true
    //        sortPopUpBottomConstraint.constant = -240
    //        UIView.animate(withDuration: 0.3, animations: {
    //            self.view.layoutIfNeeded()
    //        })
    //    }
    
    func didPressJoinBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
            //tableView.reloadData()
        }
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            //tableView.reloadData()
        }
        
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "feedToViewProfile" {
    //            if let nextVC = segue.destination as? ViewProfileVC {
    //                nextVC.selectedProfile = sender as? Users
    //            }
    //        }
    //    }
    
    func didPressProfilePic(_ tag: Int) {
        let userKey = statusArr[tag].userId
        for index in 0..<usersArr.count {
            if userKey == usersArr[index].usersKey {
                let selectedProfile = usersArr[index]
                performSegue(withIdentifier: "feedToViewProfile", sender: selectedProfile)
            }
        }
    }
    
    func didPressStatusContentLbl(_ tag: Int) {
        print(tag)
        //        let usersKey = statusArr[tag].userId
        //        for index in 0..<usersArr.count {
        //           if usersArr[index].usersKey == usersKey {
        //                print(usersArr[index].cover["source"])
        //                //send to conversation
        //            }
        //        }
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToProfile", sender: nil)
    }
    
}
