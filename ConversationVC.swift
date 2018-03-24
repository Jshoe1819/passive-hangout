//
//  ConversationVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class ConversationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var conversationUid = ""
    var originController = ""
    var selectedProfileKey = ""
    var numberLoadMores = -1
    var keyboardHeight: CGFloat = 0.0
    
    var messageList = [String]()
    var selectedProfile: Users!
    var selectedStatus: Status!
    var cellHeights = Dictionary<Int,CGFloat>()
    var messagesArr = [Messages]()
    var currentConversation: Conversation!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var headerView: CustomHeader!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    @IBOutlet weak var textInputView: ReceiverMessageColor!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var textViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textInputViewToHeader: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,0,tableView.bounds.size.width-8.5)
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        textView.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 10
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Start typing..."
        placeholderLabel.font = UIFont(name: "AvenirNext-Italic", size: 14)
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").queryOrdered(byChild: "timestamp").queryLimited(toLast: 30).observe(.value, with: { (snapshot) in
            
            self.messagesArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                    if let messageDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let message = Messages(messageKey: key, messageData: messageDict)
                        self.messagesArr.insert(message, at: 0)
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        DataService.ds.REF_CONVERSATION.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                    if let conversationDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                        if conversation.conversationKey == self.conversationUid {
                            self.currentConversation = conversation
                            return
                        }
                    }
                }
            }
            
        })
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                                
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                                
                            }
                            
                            if users.usersKey == self.selectedProfileKey {
                                self.nameLbl.text = users.name
                                self.populateProfilePicture(user: users)
                                self.selectedProfile = users
                            }
                            
                        }
                    }
                }
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").updateChildValues(["\(currentUser)" : true,
                                                                                                    "\(currentUser)Read" : ServerValue.timestamp()])
        }
        tableView.frame.origin.x += 500
        tableView.isHidden = false
        textInputView.frame.origin.x += 500
        textInputView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x -= 500
            self.textInputView.frame.origin.x -= 500
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == messagesArr.count && messagesArr.count >= 30 * numberLoadMores {
            loadMore()
        }
    }
    
    func loadMore() {
        
        if numberLoadMores > 0 {
            
            self.messagesArr = []
            
            DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(30 * numberLoadMores + 30)).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let messageDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let message = Messages(messageKey: key, messageData: messageDict)
                            self.messagesArr.insert(message, at: 0)
                        }
                    }
                }
                self.tableView.reloadData()
                self.numberLoadMores += 1
            })
            
            
            
        } else if numberLoadMores <= 0 {
            
            numberLoadMores += 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messagesArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as? ConversationCell {
            
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            
            cell.configureCell(message: message)
            
            if indexPath.row == 0 {
                if let currentUser = Auth.auth().currentUser?.uid {
                    if message.senderuid == currentUser {
                        cell.sentMsgAgeLbl.isHidden = false
                        cell.sentMsgAgeLbl.text = "Sent \(cell.configureTimeAgo(unixTimestamp: message.timestamp))"
                        
                    } else {
                        cell.receivedMsgAgeLbl.isHidden = false
                        cell.receivedMsgAgeLbl.text = "Received \(cell.configureTimeAgo(unixTimestamp: message.timestamp))"
                    }
                }
            }
            return cell
        } else {
            return ConversationCell()
        }
    }
    
    func populateProfilePicture(user: Users) {
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                self.profilePicImg.image = image
            } else {
                if user.id != "a" {
                    let profileUrl = URL(string: user.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePicImg.image = profileImage
                        ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //Handle error?
                        } else {
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profilePicImg.image = profileImage
                                    ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textView.isScrollEnabled = false
        
        if textInputView.frame.origin.y > headerView.frame.maxY + 25 {
            textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height + 10
            self.tableView.contentInset = UIEdgeInsetsMake(10, 0, keyboardHeight + textViewContainerHeightConstraint.constant, 0)
        } else {
            if textView.intrinsicContentSize.height < textViewContainerHeightConstraint.constant {
                textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height
            }
            textView.isScrollEnabled = true
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardHeight == 0.0 {
                keyboardHeight = keyboardSize.height
            }
            textViewContainerBottomConstraint.constant = keyboardHeight - (self.view.frame.maxY - footerView.frame.origin.y)
            if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
            
            
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.textViewContainerBottomConstraint.constant = 0
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        guard let messageContent = textView.text, messageContent != "" else {
            return
        }
        
        numberLoadMores = 1
        
        if let messageContent = textView.text {
            
            if let user = Auth.auth().currentUser {
                let userId = user.uid
                let key = DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").childByAutoId().key
                let message = ["content": messageContent,
                               "timestamp": ServerValue.timestamp(),
                               "senderuid": userId] as [String : Any]
                
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").updateChildValues([key : message, selectedProfile.usersKey : false, userId : true])
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/details").updateChildValues(["lastMsgContent" : messageContent, "lastMsgDate" : ServerValue.timestamp()])
                if let notMuted = currentConversation.users[selectedProfile.usersKey] as? Bool {
                    if notMuted == true {
                        DataService.ds.REF_USERS.child(selectedProfile.usersKey).updateChildValues(["hasNewMsg" : true])
                    }
                }
                
                textView.text = ""
                placeholderLabel.isHidden = false
                
                textViewContainerHeightConstraint.constant = 48
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conversationToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                if originController == "feedToViewProfile" {
                    nextVC.originController = "feedToViewProfile"
                    nextVC.selectedProfileKey = sender as! String
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "searchToViewProfile" {
                    nextVC.originController = "searchToViewProfile"
                    nextVC.selectedProfileKey = sender as! String
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "joinedListToViewProfile" {
                    nextVC.originController = "joinedListToViewProfile"
                    nextVC.selectedProfileKey = sender as! String
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "joinedFriendsToViewProfile" {
                    nextVC.originController = "joinedFriendsToViewProfile"
                    nextVC.selectedStatus = selectedStatus
                    nextVC.selectedProfileKey = sender as! String
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                }
                nextVC.selectedProfileKey = sender as! String
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
            }
        } else if segue.identifier == "conversationToFeed" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "conversationToFeed"
            }
        } else if segue.identifier == "conversationToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "conversationToMyProfile"
            }
        } else if segue.identifier == "conversationToMessages" {
            if let nextVC = segue.destination as? MessagesVC {
                nextVC.originController = "conversationToMessages"
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        if originController == "viewProfileToConversation" {
            
            let selectedProfileKey = self.selectedProfileKey
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfileKey)
            
        } else if originController == "feedToViewProfile" {
            
            let selectedProfileKey = self.selectedProfileKey
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfileKey)
        } else if originController == "searchToViewProfile" {
            
            let selectedProfileKey = self.selectedProfileKey
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfileKey)
        } else if originController == "joinedListToViewProfile" {
            
            let selectedProfileKey = self.selectedProfileKey
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfileKey)
        } else if originController == "friendsListToConversation" {
            
            performSegue(withIdentifier: "conversationToFriendsList", sender: nil)
            
        } else if originController == "joinedFriendsToViewProfile" {
            
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfileKey)
            
        }
            
        else {
            
            performSegue(withIdentifier: "conversationToMessages", sender: nil)
        }
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
            self.textInputView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "conversationToFeed", sender: nil)
        }
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
            self.textInputView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "conversationToJoinedList", sender: nil)
        }
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
            self.textInputView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "conversationToSearch", sender: nil)
        }
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
            self.textInputView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "conversationToMyProfile", sender: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if let currentUser = Auth.auth().currentUser?.uid {
            if messagesArr.count == 0 {
                DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
}
