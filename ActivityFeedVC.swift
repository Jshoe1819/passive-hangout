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
    var userFri = [String]()
    var userCity = ""
    var placeholderLabel : UILabel!
    var refreshControl: UIRefreshControl!
    var friendPostArr = [String]()
    var friendPostCount = 0
    var numberLoadMores = 1
    //var numberFromLast = 1
    //static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var textView: NewStatusTextView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var newStatusView: RoundedPopUp!
    @IBOutlet weak var statusPopupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusPopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var opaqueStatusBackground: UIButton!
    @IBOutlet weak var availableSelected: UISegmentedControl!
    @IBOutlet weak var sortPopUpBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableIndicatorImg: UIImageView!
    @IBOutlet weak var nameIndicatorImg: UIImageView!
    @IBOutlet weak var lastUpdatedIndicatorImg: UIImageView!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var newMsgChatIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
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
        //placeholderLabel.lineBreakMode = .byWordWrapping
        //placeholderLabel.numberOfLines = 0
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
                            //print(self.userFriendsList)
                        }
                        if let val = snap.value as? String {
                            if val == "friends" {
                                //                                self.userFri.append(snap.key)
                                //                                print("ALT: \(self.userFri)")
                                //                                print("HH: \(self.userFri.count)")
                                //print("hey there \(snap.key)")
                                DataService.ds.REF_USERS.child(snap.key).child("statusId").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                                        for snap in snapshot {
                                            //print("WHOA \(snap.key)")
                                            if snap.key != "a" {
                                                //print("ummm: \(snap.key)")
                                                self.friendPostArr.append(snap.key)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                //self.tableView.reloadData()
            })
            
        }
        
        
        //print("YOOO \(friendPostArr)")
        
        //        if userFri.count > 0 {
        //            print("hi honeyyyy")
        //            for index in 0..<userFri.count {
        //                DataService.ds.REF_USERS.child(userFri[index]).child("statusId").observeSingleEvent(of: .value, with: { (snapshot) in
        //                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                        for snap in snapshot {
        //                            print("HMMM: \(snap)")
        //                        }
        //                    }
        //                    //self.tableView.reloadData()
        //                })
        //            }
        //        }
        
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
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        let when = DispatchTime.now() + 0.01 // change 2 to desired number of seconds
    //        DispatchQueue.main.asyncAfter(deadline: when) {
    //            // Your code with delay
    //            self.refresh(sender: "")
    //        }
    //
    //    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        let  height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
////        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
////        if distanceFromBottom < height {
////            loadMore()
////        }
//        
//        if contentYoffset > scrollView.contentSize.height - scrollView.frame.size.height {
//            loadMore()
//        }
//        
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == statusArr.count && statusArr.count >= 10 * numberLoadMores {
//            print("do something")
//            print(statusArr.count)
//            print(friendPostCount)
            loadMore()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("UA: \(friendPostArr)")
        if friendPostCount == 0 {
            self.refresh(sender: self)
        }
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = statusArr[indexPath.row]
        let users = usersArr
        //print(status)
        
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
        newStatusView.isHidden = false
        statusPopupTopConstraint.constant = 5
        statusPopupBottomConstraint.constant = 272
        //statusPopupTopConstraint.constant = 5
        opaqueStatusBackground.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            //self.textViewDidChange(self.textView)
            self.textView.becomeFirstResponder()
            //self.availableSelected.selectedSegmentIndex = 0
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
            self.characterCountLbl.isHidden = true
            self.textView.text = ""
            self.cityTextField.text = self.userCity
        })
        newStatusView.isHidden = true
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
    
    //    func setAvailable(segmentControl: UISegmentedControl) -> Bool {
    //        if segmentControl.selectedSegmentIndex == 0 {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }
    
    @IBAction func saveStatusBtnPressed(_ sender: Any) {
        guard let statusContent = textView.text, statusContent != "" else {
            return
        }
        
        if let statusContent = textView.text {
            //print("JAKE: \(statusContent)")
            if let user = Auth.auth().currentUser {
                let userId = user.uid
                if let city = cityTextField.text {
                    let key = DataService.ds.REF_BASE.child("status").childByAutoId().key
                    let status = [//"available": setAvailable(segmentControl: availableSelected),
                        "content": statusContent,
                        "joinedList": ["seen": true],
                        "joinedNumber": 0,
                        "city": city,
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
                        //                        self.textView.resignFirstResponder()
                        //                        self.characterCountLbl.isHidden = true
                        //                        self.textView.text = ""
                        //                        self.cityTextField.text = self.userCity
                    })
                    self.textView.resignFirstResponder()
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
                nextVC.selectedProfile = sender as? Users
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                nextVC.originController = "feedToViewProfile"
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
            //tableView.reloadData()
        }
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count-1])
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
        //print(tag)
        //send to conversation
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "activityFeedToProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
    func loadMore() {
        
        //numberLoadMores += 1
        //print(numberLoadMores)
        
        //statusArr = []
        self.isEmptyImg.isHidden = true
        
        if friendPostArr != [] && friendPostArr.count < (numberLoadMores + 1) * 10 {
            print("hi")
            friendPostCount = friendPostArr.count
            for index in numberLoadMores * 10..<friendPostArr.count {
                //print(index)
                //print("im trying here \(friendPostArr.sorted()[index])")
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("snapshot: \(snapshot)")
                    //self.statusArr = []
                    
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        //print("friends - \(status.userId)")
                        //self.statusArr.insert(status, at: 0)
                        self.statusArr.append(status)
                        //print(self.statusArr)
                        
                        //what if i allow 30 from last to load at a time
                        //if the arr is less than 10 load more until greater than 10
                        //end this function
                        
                        //or create list of all friends posts, sort, cycle through, limit to xx until bottom**
                        
                        //write function to trigger a more load that allows loading until arr > count + 10 and continue
                        
                        //                        if self.statusArr.count > 9 {
                        //                            print("\(self.statusArr.count)")
                        //                            break
                        //                        }
                        
                        //self.statusArr.insert(status, at: 0)
                    }
                    
                    //                    if self.statusArr.count == 0 {
                    //                        self.isEmptyImg.isHidden = false
                    //                    } else {
                    //                        self.isEmptyImg.isHidden = true
                    //                    }
                    //print("this one:: \(self.statusArr)")
                    self.tableView.reloadData()
                })
                numberLoadMores += 1
            }
        } else if friendPostArr != [] && friendPostArr.count >= numberLoadMores * 10 {
            print("bye")
            friendPostCount = friendPostArr.count
            for index in numberLoadMores * 10..<(numberLoadMores + 1) * 10 {
                //print(index)
                //print("im trying here \(friendPostArr.sorted()[index])")
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("snapshot: \(snapshot)")
                    //self.statusArr = []
                    
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        //print("friends - \(status.userId)")
                        //self.statusArr.insert(status, at: 0)
                        self.statusArr.append(status)
                        //print(self.statusArr)
                        
                        //what if i allow 30 from last to load at a time
                        //if the arr is less than 10 load more until greater than 10
                        //end this function
                        
                        //or create list of all friends posts, sort, cycle through, limit to xx until bottom**
                        
                        //write function to trigger a more load that allows loading until arr > count + 10 and continue
                        
                        //                        if self.statusArr.count > 9 {
                        //                            print("\(self.statusArr.count)")
                        //                            break
                        //                        }
                        
                        //self.statusArr.insert(status, at: 0)
                    }
                    
                    //                    if self.statusArr.count == 0 {
                    //                        self.isEmptyImg.isHidden = false
                    //                    } else {
                    //                        self.isEmptyImg.isHidden = true
                    //                    }
                    //print("this one:: \(self.statusArr)")
                    self.tableView.reloadData()
                })
                numberLoadMores += 1
            }
        } else if friendPostArr.count == 0 {
            friendPostCount = friendPostArr.count
            self.isEmptyImg.isHidden = false
        }
    }
    
    func refresh(sender: Any) {
        
        statusArr = []
        self.isEmptyImg.isHidden = true
        numberLoadMores = 1
        
        //        if let currentUser = Auth.auth().currentUser?.uid {
        //            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
        //                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                    for snap in snapshot {
        //                        if let value = snap.value {
        //                            //                            if value == "friends" {
        //                            //                                self.userFriendsList.updateValue(value, forKey: snap.key)
        //                            //                                print(value)
        //                            //                            }
        //                            self.userFriendsList.updateValue(value, forKey: snap.key)
        //                            //print(self.userFriendsList)
        //                        }
        //                    }
        //                }
        //                //self.tableView.reloadData()
        //            })
        //        }
        //        for friend in 0..<userFriendsList.count {
        //            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
        //                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                    for snap in snapshot {
        //                        if let value = snap.value {
        //                            self.userFriendsList.updateValue(value, forKey: snap.key)
        //                            //print(self.userFriendsList)
        //                        }
        //                    }
        //                }
        //                //self.tableView.reloadData()
        //            })
        //        }
        
        //print("working?? \(friendPostArr)")
        
        if friendPostArr != [] && friendPostArr.count < 10 {
            friendPostCount = friendPostArr.count
            for index in 0..<friendPostArr.count {
                //print("im trying here \(friendPostArr.sorted()[index])")
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("snapshot: \(snapshot)")
                    //self.statusArr = []
                    
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        //print("friends - \(status.userId)")
                        //self.statusArr.insert(status, at: 0)
                        self.statusArr.append(status)
                        //print(self.statusArr)
                        
                        //what if i allow 30 from last to load at a time
                        //if the arr is less than 10 load more until greater than 10
                        //end this function
                        
                        //or create list of all friends posts, sort, cycle through, limit to xx until bottom**
                        
                        //write function to trigger a more load that allows loading until arr > count + 10 and continue
                        
                        //                        if self.statusArr.count > 9 {
                        //                            print("\(self.statusArr.count)")
                        //                            break
                        //                        }
                        
                        //self.statusArr.insert(status, at: 0)
                    }
                    
                    //                    if self.statusArr.count == 0 {
                    //                        self.isEmptyImg.isHidden = false
                    //                    } else {
                    //                        self.isEmptyImg.isHidden = true
                    //                    }
                    //print("this one:: \(self.statusArr)")
                    self.tableView.reloadData()
                })
            }
        } else if friendPostArr != [] && friendPostArr.count >= 10 {
            friendPostCount = friendPostArr.count
            for index in 0..<10 {
                //print("im trying here \(friendPostArr.sorted()[index])")
                DataService.ds.REF_STATUS.child(friendPostArr.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print("snapshot: \(snapshot)")
                    //self.statusArr = []
                    
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        //print("friends - \(status.userId)")
                        //self.statusArr.insert(status, at: 0)
                        self.statusArr.append(status)
                        //print(self.statusArr)
                        
                        //what if i allow 30 from last to load at a time
                        //if the arr is less than 10 load more until greater than 10
                        //end this function
                        
                        //or create list of all friends posts, sort, cycle through, limit to xx until bottom**
                        
                        //write function to trigger a more load that allows loading until arr > count + 10 and continue
                        
                        //                        if self.statusArr.count > 9 {
                        //                            print("\(self.statusArr.count)")
                        //                            break
                        //                        }
                        
                        //self.statusArr.insert(status, at: 0)
                    }
                    
                    //                    if self.statusArr.count == 0 {
                    //                        self.isEmptyImg.isHidden = false
                    //                    } else {
                    //                        self.isEmptyImg.isHidden = true
                    //                    }
                    //print("this one:: \(self.statusArr)")
                    self.tableView.reloadData()
                })
            }
        } else if friendPostArr.count == 0 {
            friendPostCount = friendPostArr.count
            self.isEmptyImg.isHidden = false
        }
        
        //        if userFri.count > 0 {
        //            print("hi honeyyyy")
        //            for index in 0..<userFri.count {
        //                DataService.ds.REF_USERS.child(userFri[index]).child("statusId").observeSingleEvent(of: .value, with: { (snapshot) in
        //                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                        for snap in snapshot {
        //                            print("HMMM: \(snap)")
        //                        }
        //                    }
        //                    //self.tableView.reloadData()
        //                })
        //            }
        //        }
        
        
        //        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //            self.statusArr = []
        //
        //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                for snap in snapshot {
        //
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
        //
        //                        //what if i allow 30 from last to load at a time
        //                        //if the arr is less than 10 load more until greater than 10
        //                        //end this function
        //
        //                        //or create list of all friends posts, sort, cycle through, limit to xx until bottom**
        //
        //                        //write function to trigger a more load that allows loading until arr > count + 10 and continue
        //
        //                        //                        if self.statusArr.count > 9 {
        //                        //                            print("\(self.statusArr.count)")
        //                        //                            break
        //                        //                        }
        //
        //                        //self.statusArr.insert(status, at: 0)
        //                    }
        //                }
        //            }
        //
        //            if self.statusArr.count == 0 {
        //                self.isEmptyImg.isHidden = false
        //            } else {
        //                self.isEmptyImg.isHidden = true
        //            }
        //
        //            self.tableView.reloadData()
        //        })
        
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
        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //            if self.statusArr.count == 0 {
            //                self.isEmptyImg.isHidden = false
            //            } else {
            //                self.isEmptyImg.isHidden = true
            //            }
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
    }
}
