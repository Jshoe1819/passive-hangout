//
//  PastStatusesVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

class PastStatusesVC: UIViewController, PastStatusCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelEditBtn: UIButton!
    @IBOutlet weak var saveEditBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    
    var statusArr = [Status]()
    var tappedBtnTags = [Int]()
    var deleted = [Int]()
    var originController = ""
    var selectedUserStatuses = [Status]()
    var viewedProfile: Users!
    var maximumY:CGFloat!
    var status: Status!
    var selectedStatus: Status!
    var searchText = ""
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PastStatusesVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PastStatusesVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = UIColor.purple
        refreshControl.addTarget(self, action: #selector(ActivityFeedVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        isEmptyImg.isHidden = true
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if status.userId == currentUser {
                                self.statusArr.insert(status, at: 0)
                            }
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
            profilePicImg.isHidden = false
            populateProfilePicture(user: viewedProfile)
            nameLbl.text = viewedProfile.name
            //isEmptyImg.isHidden = (selectedUserStatuses.count == 0) ? false : true
        } else {
            //print("HEY: \(self.statusArr.count)")
            //self.isEmptyImg.isHidden = (self.statusArr.count == 0) ? false : true
        }
        
    }
    
    func populateProfilePicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.profilePicImg.image = image
            } else {
                //print("not in cache")
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
        
        
        
        //print("JAKE: going in to else")
        //        if user.id != "a" {
        //            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
        //                profilePicImg.image = image
        //                //print("JAKE: Cache working")
        //            } else {
        //                let profileUrl = URL(string: user.profilePicUrl)
        //                let data = try? Data(contentsOf: profileUrl!)
        //                if let profileImage = UIImage(data: data!) {
        //                    self.profilePicImg.image = profileImage
        //                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
        //                }
        //            }
        //
        //        } else {
        //            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
        //                profilePicImg.image = image
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
        //                                self.profilePicImg.image = image
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
            //print("hi")
            return selectedUserStatuses.count
        }
        //print("bye")
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
            //            if selectedUserStatuses.count == 0 {
            //                isEmptyImg.isHidden = false
            //                print("yol")
            //            } else {
            //                print("lol")
            //                isEmptyImg.isHidden = true
            //            }
            status = selectedUserStatuses[indexPath.row]
            isEmptyImg.isHidden = (selectedUserStatuses.count == 0) ? false : true
            //print("hil")
        } else {
            //            if statusArr.count == 0 {
            //                print("yo")
            //                isEmptyImg.isHidden = false
            //            } else {
            //                print("lo")
            //                isEmptyImg.isHidden = true
            //            }
            status = statusArr[indexPath.row]
            isEmptyImg.isHidden = (statusArr.count == 0) ? false : true
            // causing index out of range error
            //print("byel")
        }
        
        //status = statusArr[indexPath.row] // causing index out of range error
        //        print("byel")
        //print(statusArr[indexPath.row].content)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PastStatusesCell") as? PastStatusesCell {
            
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.menuBtn.tag = indexPath.row
            cell.textView.isHidden = true
            cell.contentLbl.isHidden = false
            cell.configureCell(status: status)
            
            if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
                //cell.configureCell(status: selectedUserStatuses[indexPath.row])
                if let currentUser = Auth.auth().currentUser?.uid {
                    let join = status.joinedList.keys.contains { (key) -> Bool in
                        key == currentUser
                    }
                    if join {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = false
                    } else{
                        cell.joinBtn.isHidden = false
                        cell.alreadyJoinedBtn.isHidden = true
                    }
                    cell.menuBtn.isHidden = true
                    cell.numberJoinedLbl.isHidden = true
                    cell.newJoinIndicator.isHidden = true
                    
                }
            }
            
            if deleted.contains(indexPath.row) {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            
            if tappedBtnTags.count > 0 {
                cell.menuBtn.isEnabled = false
                
                //print("\(tappedBtnTags)")
            } else {
                //cell.menuBtn.addTarget(self, action: #selector(self.didPressMenuBtn(_:textView:label:button:)), for: .touchUpInside)
                cell.menuBtn.isEnabled = true
                //print("\(tappedBtnTags)")
            }
            
            //disable cell clicking
            //cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        } else {
            return PastStatusesCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //perform joinedlist segue
        //        DataService.ds.REF_CONVERSATION.child("\(conversationArr[indexPath.row].conversationKey)/messages").updateChildValues(["read" : true])
        //        let selectedConversation = conversationArr[indexPath.row].conversationKey
        //        performSegue(withIdentifier: "messagesToConversation", sender: selectedConversation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
            let alert = UIAlertController(title: "Delete Hangout", message: "Are you sure you would like to delete this hangout?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
//                if let currentUser = Auth.auth().currentUser?.uid {
//                    DataService.ds.REF_STATUS.child(self.statusArr[indexPath.row].statusKey).removeValue()
//                    DataService.ds.REF_USERS.child(currentUser).child("statusId").child(self.statusArr[indexPath.row].statusKey).removeValue()
//                    self.deleted.append(indexPath.row)
//                }
                print("DELETED \(indexPath.row)")
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                
                //textView.isHidden = true
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        deleteAction.backgroundColor = UIColor.red
        
        
        let editAction = UITableViewRowAction(style: .normal, title: " Edit ") { (rowAction, indexPath) in
            tableView.setEditing(true, animated: true)
            if tableView.isEditing == true{
                //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
            }else{
                //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
            }
            print(indexPath.row)
            
        }
        editAction.backgroundColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        
        return [deleteAction, editAction]
    }
    
    func didPressMenuBtn(_ tag: Int, textView: UITextView, label: UILabel, button: UIButton) {
        //print("I have pressed menu button with tag: \(tag)")
        textView.delegate = self
        tappedBtnTags.append(tag)
        //print("JAKE: \(tappedBtnTags)")
        tableView.reloadData()
        
        let rectOfCellInTableView = self.tableView.rectForRow(at: IndexPath(row: tag, section: 0))
        let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
        let maxY = rectOfCellInSuperview.origin.y + rectOfCellInSuperview.height
        self.maximumY = maxY
        
        //print("Y of Cell is: \(rectOfCellInSuperview.origin.y)")
        //print("Height of Cell is: \(rectOfCellInSuperview.height)")
        
        // create the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            // create the alert
            let alert = UIAlertController(title: "Delete Status", message: "Are you sure you would like to delete this status?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
                if let currentUser = Auth.auth().currentUser?.uid {
                    DataService.ds.REF_STATUS.child(self.statusArr[tag].statusKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("statusId").child(self.statusArr[tag].statusKey).removeValue()
                    self.deleted.append(tag)
                }
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                
                //textView.isHidden = true
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { action in
            
            //button.isHidden = true
            label.isHidden = true
            textView.isHidden = false
            textView.text = label.text
            //textView.becomeFirstResponder() //error probably because called too early
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
            
            
            //tableView.setContentOffset(CGPoint(tag), animated: true)
            
            self.backBtn.isHidden = true
            //self.saveEditBtn.isHidden = false
            
            self.saveEditBtn.isHidden = false
            self.cancelEditBtn.isHidden = false
            self.saveEditBtn.tag = tag
            self.cancelEditBtn.tag = tag
            
            self.saveEditBtn.addTarget(self, action: #selector(PastStatusesVC.saveEditBtnPressed), for: .touchUpInside)
            self.saveEditBtn.layer.setValue(tag, forKey: "tag")
            self.saveEditBtn.layer.setValue(textView.text, forKey: "text")
            self.saveEditBtn.layer.setValue(textView, forKey: "textview")
            
            //            let rectOfCellInTableView = self.tableView.rectForRow(at: IndexPath(row: tag, section: 0))
            //            let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
            //            let maxY = rectOfCellInSuperview.origin.y + rectOfCellInSuperview.height
            //            self.maximumY = maxY
            textView.becomeFirstResponder()
        }))
        
        alert.addAction(UIAlertAction(title: "Joined", style: UIAlertActionStyle.default, handler: { action in
            
            //textView.isHidden = true
            let statusKey = self.statusArr[tag].statusKey
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "true"])
            self.performSegue(withIdentifier: "pastStatusesToJoinedFriends", sender: self.statusArr[tag])
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            //textView.isHidden = true
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if deleted.contains(indexPath.row) {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.saveEditBtn.layer.setValue(textView.text, forKey: "text")
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
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.tableView.frame.origin.y == 67{
                //print("h: \(maximumY - keyboardSize.minY)")
                if maximumY > (keyboardSize.minY) { //causing unwrapped nil fail
                    //print("entering")
                    self.tableView.isScrollEnabled = false
                    //print(keyboardSize.minY)
                    self.tableView.frame.origin.y -= (maximumY - keyboardSize.minY)
                    
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if self.tableView.frame.origin.y != 67{
            self.tableView.isScrollEnabled = true
            //print(keyboardSize.minY)
            self.tableView.frame.origin.y = 67
            
        }
        //}
    }
    
    func didPressJoinBtn(_ tag: Int) {
        //print("I have pressed a join button with a tag: \(tag)")
        let statusKey = selectedUserStatuses[tag].statusKey
        let userKey = selectedUserStatuses[tag].userId
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true"])
            DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
            //tableView.reloadData()
        }
        
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        //print("I have pressed already join button with a tag: \(tag)")
        let statusKey = selectedUserStatuses[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            //tableView.reloadData()
        }
    }
    
    func didPressJoinedList(_ tag: Int) {
        //print(statusArr[tag].joinedList)
        let statusKey = statusArr[tag].statusKey
        DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "true"])
        performSegue(withIdentifier: "pastStatusesToJoinedFriends", sender: statusArr[tag])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pastStatusesToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                if originController == "feedToViewProfile" {
                    nextVC.originController = "feedToViewProfile"
                } else if originController == "searchToViewProfile" {
                    nextVC.originController = "searchToViewProfile"
                    nextVC.searchText = searchText
                } else if originController == "joinedFriendsToViewProfile" {
                    nextVC.originController = "joinedFriendsToViewProfile"
                    nextVC.selectedStatus = selectedStatus
                    nextVC.selectedProfile = viewedProfile
                }
            }
        }
        if segue.identifier == "pastStatusesToJoinedFriends" {
            if let nextVC = segue.destination as? JoinedFriendsVC {
                nextVC.selectedStatus = sender as? Status
            }
        }
    }
    
    @IBAction func saveEditBtnPressed(_ sender: UIButton) {
        
        if let text = sender.layer.value(forKey: "text") {
            if let tag = sender.layer.value(forKey: "tag") as? Int {
                DataService.ds.REF_STATUS.updateChildValues(["/\(statusArr[tag].statusKey)/content": text])
                //print("TAG: \(tag), TEXT: \(text)")
                hideKeyboard()
                backBtn.isHidden = false
                cancelEditBtn.isHidden = true
                saveEditBtn.isHidden = true
                refresh(sender: "")
                tappedBtnTags.removeAll()
                tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func cancelEditBtnPressed(_ sender: UIButton) {
        hideKeyboard()
        backBtn.isHidden = false
        cancelEditBtn.isHidden = true
        saveEditBtn.isHidden = true
        tappedBtnTags.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        if originController == "viewProfileToPastStatuses" || originController == "feedToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
            performSegue(withIdentifier: "pastStatusesToViewProfile", sender: viewedProfile)
        } else {
            performSegue(withIdentifier: "pastStatusesToMyProfile", sender: nil)
        }
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToActivityFeed", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToJoinedList", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToSearch", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToMyProfile", sender: nil)
        //footerNewFriendIndicator.isHidden = true
    }
    
    func refresh(sender: Any) {
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if status.userId == currentUser {
                                self.statusArr.insert(status, at: 0)
                            }
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
            profilePicImg.isHidden = false
            populateProfilePicture(user: viewedProfile)
        }
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}
