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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var textView: NewStatusTextView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var newStatusView: RoundedPopUp!
    @IBOutlet weak var statusPopupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusPopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var opaqueStatusBackground: UIButton!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var newMsgChatIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    @IBOutlet weak var characterCountLbl: UILabel!
    
    var statusArr = [Status]()
    var usersArr = [Users]()
    var userFriendsList = Dictionary<String, Any>()
    var placeholderLabel : UILabel!
    var refreshControl: UIRefreshControl!
    var friendPostArr = [String]()
    var unjoinedArr = [String]()
    var joinedKeys = [String]()
    
    var userCity = ""
    var originController = ""
    var friendPostCount = 0
    var numberLoadMores = 1
    var refreshCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil {
            if let currentUser = Auth.auth().currentUser?.uid {
                if let facebookId = FBSDKAccessToken.current().userID {
                    let profilePicUrl = "https://graph.facebook.com/\(facebookId)/picture?type=large"
                    let picUpdate = ["\(currentUser)/profilePicUrl": profilePicUrl] as Dictionary<String, Any>
                    DataService.ds.REF_USERS.updateChildValues(picUpdate)
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        refreshControl.addTarget(self, action: #selector(ActivityFeedVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        placeholderLabel = UILabel()
        placeholderLabel.text = EMPTY_STATUS_STRING
        placeholderLabel.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        cityTextField.attributedPlaceholder = NSAttributedString(string: "City",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-UltralightItalic", size: 16) as Any])
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value {
                            self.userFriendsList.updateValue(value, forKey: snap.key)
                        }
                        if let val = snap.value as? String {
                            if val == "friends" {
                                DataService.ds.REF_USERS.child(snap.key).child("statusId").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                                        for snap in snapshot {
                                            if snap.key != "a" {
                                                self.friendPostArr.append(snap.key)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if originController == "" {
            tableView.isHidden = false
            return
        }
        
        if originController != "messagesToFeed" && originController != "conversationToFeed" {

            tableView.frame.origin.x -= 500
            isEmptyImg.frame.origin.x -= 500
            tableView.isHidden = false
            
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame.origin.x += 500
                self.isEmptyImg.frame.origin.x += 500
            }
            
        } else if originController == "messagesToFeed" || originController == "conversationToFeed" {
            tableView.isHidden = false
            return
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendPostCount == 0 && refreshCount < 8 {
            self.refresh(sender: self)
        } else if friendPostCount == 0 && refreshCount >= 8 {
            self.isEmptyImg.isHidden = false
            UIView.animate(withDuration: 0.75) {
                self.isEmptyImg.alpha = 1.0
            }
        } else {
            self.isEmptyImg.isHidden = true
            self.isEmptyImg.alpha = 0
        }
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
                if (join && !unjoinedArr.contains(status.statusKey)) || joinedKeys.contains(status.statusKey) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == statusArr.count && statusArr.count >= 10 * numberLoadMores {
            loadMore()
        }
    }
    
    @IBAction func newStatusBtn(_ sender: Any) {
        newStatusView.isHidden = false
        statusPopupTopConstraint.constant = 5
        statusPopupBottomConstraint.constant = 272
        opaqueStatusBackground.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textView.becomeFirstResponder()
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        characterCountLbl.isHidden = false
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
    
    @IBAction func cancelNewStatus(_ sender: Any) {
        statusPopupBottomConstraint.constant = -325
        statusPopupTopConstraint.constant = 680
        opaqueStatusBackground.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textView.resignFirstResponder()
            
            self.characterCountLbl.isHidden = true
            self.textView.text = ""
            self.cityTextField.text = self.userCity
        })
        newStatusView.isHidden = true
    }
    
    @IBAction func saveStatusBtnPressed(_ sender: Any) {
        guard let statusContent = textView.text, statusContent != "" else {
            return
        }
        
        if let statusContent = textView.text {
            if let currentUser = Auth.auth().currentUser?.uid {
                if let city = cityTextField.text {
                    let key = DataService.ds.REF_BASE.child("status").childByAutoId().key
                    let status = [
                        "content": statusContent,
                        "joinedList": ["seen": true],
                        "joinedNumber": 0,
                        "city": city.lowercased(),
                        "postedDate": ServerValue.timestamp(),
                        "userId": currentUser] as [String : Any]
                    let childUpdates = ["/status/\(key)": status,
                                        "/users/\(currentUser)/statusId/\(key)/": true] as Dictionary<String, Any>

                    DataService.ds.REF_BASE.updateChildValues(childUpdates)
                    
                    refresh(sender: "")
                    
                    statusPopupBottomConstraint.constant = -325
                    statusPopupTopConstraint.constant = 680
                    opaqueStatusBackground.isHidden = true
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                        self.textView.resignFirstResponder()
                        self.cityTextField.resignFirstResponder()
                    })
                    
                    self.characterCountLbl.isHidden = true
                    self.textView.text = ""
                    self.cityTextField.text = self.userCity
                    newStatusView.isHidden = true
                    
                }
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
                nextVC.selectedProfileKey = sender as! String
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                nextVC.originController = "feedToViewProfile"
            }
        } else if segue.identifier == "activityFeedToProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "activityFeedToProfile"
            }
        } else if segue.identifier == "activityFeedToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "activityFeedToJoinedList"
            }
        } else if segue.identifier == "homeToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "homeToSearch"
            }
        }
    }
    
    @IBAction func msgBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "feedToMessages", sender: nil)
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
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count])
            
            joinedKeys.append(statusKey)
            
            for index in 0..<unjoinedArr.count {
                if unjoinedArr[index] == statusKey {
                    unjoinedArr.remove(at: index)
                    break
                }
            }
            
        }
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count-1])
            
            unjoinedArr.append(statusKey)
            
            for index in 0..<joinedKeys.count {
                if joinedKeys[index] == statusKey {
                    joinedKeys.remove(at: index)
                    break
                }
            }
        }
    }
    
    func didPressProfilePic(_ tag: Int) {
        let userKey = statusArr[tag].userId
        for index in 0..<usersArr.count {
            if userKey == usersArr[index].usersKey {
                let selectedProfileKey = usersArr[index].usersKey
                performSegue(withIdentifier: "feedToViewProfile", sender: selectedProfileKey)
            }
        }
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
    func loadMore() {
        
        if friendPostArr != [] && friendPostArr.count < (numberLoadMores + 1) * 10 {
            friendPostCount = friendPostArr.count
            
            for index in numberLoadMores * 10..<friendPostArr.count {
                
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                        
                    }
                    
                    self.tableView.reloadData()
                })
                
                numberLoadMores += 1
            }
            
        } else if friendPostArr != [] && friendPostArr.count >= numberLoadMores * 10 {
            friendPostCount = friendPostArr.count
            
            for index in numberLoadMores * 10..<(numberLoadMores + 1) * 10 {
                
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                })
                numberLoadMores += 1
            }
            
        } else if friendPostArr.count == 0 {
            friendPostCount = friendPostArr.count
        }
    }
    
    func refresh(sender: Any) {
        
        statusArr = []
        self.isEmptyImg.isHidden = true
        self.isEmptyImg.alpha = 0.0
        numberLoadMores = 1
        refreshCount += 1
        
        if friendPostArr != [] && friendPostArr.count < 10 {
            friendPostCount = friendPostArr.count
            
            for index in 0..<friendPostArr.count {
                
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)

                    }
                    self.tableView.reloadData()
                    
                })
            }
            
        } else if friendPostArr != [] && friendPostArr.count >= 10 {
            friendPostCount = friendPostArr.count
            for index in 0..<10 {

                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in

                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                    }
                    
                    self.tableView.reloadData()
                    
                })
            }
            
        } else if friendPostArr.count == 0 {
            friendPostCount = friendPostArr.count
        }

        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {

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
                                self.newMsgChatIndicator.isHidden = !users.hasNewMsg
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                                self.userCity = users.currentCity
                                self.cityTextField.text = self.userCity
                                
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.refreshControl.endRefreshing()
        }
    }
}
