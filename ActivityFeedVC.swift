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
    var userFriendsList = Dictionary<String, Any>()
    var userCity = ""
    var placeholderLabel : UILabel!
    var refreshControl: UIRefreshControl!
    //static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
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
    @IBOutlet weak var characterCountLbl: UILabel!
    
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
        
        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = UIColor.purple
        refreshControl.addTarget(self, action: #selector(ActivityFeedVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
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
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value {
                            self.userFriendsList.updateValue(value, forKey: snap.key)
                            //print(self.userFriendsList)
                        }
                    }
                }
                //self.tableView.reloadData()
            })
        }
        
//        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            self.statusArr = []
//            
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    //print("STATUS: \(snap)")
//                    if let statusDict = snap.value as? Dictionary<String, Any> {
//                        let key = snap.key
//                        let status = Status(statusKey: key, statusData: statusDict)
//                        let friends = self.userFriendsList.keys.contains { (key) -> Bool in
//                            status.userId == key
//                        }
//                        if friends {
//                            if self.userFriendsList[status.userId] as? String == "friends" {
//                                //print("friends - \(status.userId)")
//                                self.statusArr.insert(status, at: 0)
//                                //print(self.statusArr)
//                            }
//                        }
//                        //self.statusArr.insert(status, at: 0)
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })
//        
//        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            self.usersArr = []
//            
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    //print("USERS: \(snap)")
//                    if let usersDict = snap.value as? Dictionary<String, Any> {
//                        let key = snap.key
//                        let users = Users(usersKey: key, usersData: usersDict)
//                        if let currentUser = Auth.auth().currentUser?.uid {
//                            if currentUser == users.usersKey {
//                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
//                                    value as? String == "received"
//                                }
//                                if newFriend && users.friendsList["seen"] as? String == "false" {
//                                    self.footerNewFriendIndicator.isHidden = false
//                                }
//                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
//                                    value as? String == "false"
//                                }
//                                if newJoin {
//                                    self.footerNewFriendIndicator.isHidden = false
//                                }
//                                
//                            }
//                        }
//                        self.usersArr.append(users)
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        refresh(sender: "")
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
        //print(status)
        
        if statusArr.count == 0 {
            print("empty, show label or img")
        }
        
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
        characterCountLbl.text = "\(textView.text.characters.count) / \(CHARACTER_LIMIT) characters used"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.contains("\n") {
            return false
        }
        
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
                              "joinedList": ["seen": true],
                              "joinedNumber": 0,
                              "city": userCity,
                              "postedDate": ServerValue.timestamp(),
                              "userId": userId] as [String : Any]
                let childUpdates = ["/status/\(key)": status,
                                    "/users/\(userId)/statusId/\(key)/": true] as Dictionary<String, Any>
                //print("JAKE: \(childUpdates)")
                DataService.ds.REF_BASE.updateChildValues(childUpdates)
                refresh(sender: "")
                
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
        if tableView.contentOffset != CGPoint.zero {
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "feedToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                nextVC.originController = "feedToViewProfile"
            }
        }
    }
        
    @IBAction func msgBtnPressed(_ sender: Any) {
        print("message btn pressed")
    }
    
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToJoinedList", sender: self)
    }
    
    func didPressJoinBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        let userKey = statusArr[tag].userId
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true"])
            DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
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
        //send to conversation
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
    func refresh(sender: Any) {
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value {
                            self.userFriendsList.updateValue(value, forKey: snap.key)
                            //print(self.userFriendsList)
                        }
                    }
                }
                //self.tableView.reloadData()
            })
        }
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        let friends = self.userFriendsList.keys.contains { (key) -> Bool in
                            status.userId == key
                        }
                        if friends {
                            if self.userFriendsList[status.userId] as? String == "friends" {
                                //print("friends - \(status.userId)")
                                self.statusArr.insert(status, at: 0)
                                //print(self.statusArr)
                            }
                        }
                        //self.statusArr.insert(status, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if currentUser == users.usersKey {
                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if newFriend && users.friendsList["seen"] as? String == "false" {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
                                    value as? String == "false"
                                }
                                if newJoin {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                self.userCity = users.currentCity
                                
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
        
        
    }
    
}
