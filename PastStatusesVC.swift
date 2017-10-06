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

class PastStatusesVC: UIViewController, PastStatusCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        NotificationCenter.default.addObserver(self, selector: #selector(PastStatusesVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PastStatusesVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            
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
            //self.tableView.reloadData()
        })
        
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" {
            profilePicImg.isHidden = false
            populateProfilePicture(user: viewedProfile)
        }
        
    }
    
    func populateProfilePicture(user: Users) {
        
        //print("JAKE: going in to else")
        if user.id != "a" {
            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
                profilePicImg.image = image
                //print("JAKE: Cache working")
            } else {
                let profileUrl = URL(string: user.profilePicUrl)
                let data = try? Data(contentsOf: profileUrl!)
                if let profileImage = UIImage(data: data!) {
                    self.profilePicImg.image = profileImage
                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
                }
            }
            
        } else {
            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
                profilePicImg.image = image
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
                                self.profilePicImg.image = image
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" {
            return selectedUserStatuses.count
        } else {
            return statusArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var status: Status
        
        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" {
            status = selectedUserStatuses[indexPath.row]
        } else {
            status = statusArr[indexPath.row]
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PastStatusesCell") as? PastStatusesCell {
            
            cell.cellDelegate = self
            cell.tag = indexPath.row
            //cell.menuBtn.tag = indexPath.row
            cell.textView.isHidden = true
            cell.contentLbl.isHidden = false
            cell.configureCell(status: status)
            
            if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" {
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
    
    func didPressMenuBtn(_ tag: Int, textView: UITextView, label: UILabel, button: UIButton) {
        //print("I have pressed menu button with tag: \(tag)")
        textView.delegate = self
        tappedBtnTags.append(tag)
        //print("JAKE: \(tappedBtnTags)")
        tableView.reloadData()
        
        // create the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { action in
            
            //button.isHidden = true
            label.isHidden = true
            textView.isHidden = false
            textView.text = label.text
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
            
            textView.becomeFirstResponder()
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
            
            let rectOfCellInTableView = self.tableView.rectForRow(at: IndexPath(row: tag, section: 0))
            let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
            let maxY = rectOfCellInSuperview.origin.y + rectOfCellInSuperview.height
            print(maxY)
            
            print("Y of Cell is: \(rectOfCellInSuperview.origin.y)")
            print("Height of Cell is: \(rectOfCellInSuperview.height)")
            
            
//            if let keyboardSize = (userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                print(keyboardSize.minY)
//            
//            }
            
            //if maxy is greater than keyboard miny - shift up by difference
            //else do not shift
            
        }))
        
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
            return 84
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height - 50
            }
        }
    }
    
    func didPressJoinBtn(_ tag: Int) {
        //print("I have pressed a join button with a tag: \(tag)")
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
        //print("I have pressed already join button with a tag: \(tag)")
        let statusKey = selectedUserStatuses[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            //tableView.reloadData()
        }
    }
    
    func didPressJoinedList(_ tag: Int) {
        print(statusArr[tag].joinedList)
        let statusKey = statusArr[tag].statusKey
        DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "true"])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if let currentUser = Auth.auth().currentUser?.uid {
        //            let currentProfile = usersArr
        //        }
        
        if segue.identifier == "pastStatusesToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                if originController == "feedToViewProfile" {
                    nextVC.originController = "feedToViewProfile"
                }
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
        
        if originController == "viewProfileToPastStatuses" || originController == "feedToViewProfile" || originController == "feedToViewProfile" {
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
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToMyProfile", sender: nil)
    }
    
}
