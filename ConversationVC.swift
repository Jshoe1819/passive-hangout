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
    var selectedProfile: Users!
    var selectedStatus: Status!
    var keyboardHeight: CGFloat!
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
    @IBOutlet weak var shiftView: UIView!
    @IBOutlet weak var tvHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textInputViewToHeader: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,0,tableView.bounds.size.width-8.5)
        
        //print(textInputView.frame.origin)
        print(originController)
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 10
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Start typing..."
        placeholderLabel.font = UIFont(name: "AvenirNext-Italic", size: 14)
        textView.addSubview(placeholderLabel)
        //placeholderLabel.preferredMaxLayoutWidth = CGFloat(tableView.frame.width)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        //placeholderLabel.lineBreakMode = .byWordWrapping
        //placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        //self.conversationUid = "uid3"
        
        //load x amount, incorporate load more
        DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
            
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
        
        //time not duration
        //insert at 0, reverse array, scroll to bottom
        //grow textview input
        //use read not a in conversation msgs
        //best way to load on VDL
        //paging
        //delete deleted post everywhere
        
        
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
                            let otherUser = self.currentConversation.users.keys.contains(users.usersKey) && users.usersKey != currentUser
                            if otherUser {
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
        
//        if self.messagesArr.count > 0 {
//            self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
//            //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
//        }
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").updateChildValues(["\(currentUser)" : true])
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messagesArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as? ConversationCell {
            //            cell.receiverBubble.frame.size.height = 0
            //            cell.receivedMsgAgeLbl.frame.size.height = 0
            //            cell.senderBubble.frame.size.height = 0
            //            cell.sentMsgAgeLbl.frame.size.height = 0
            //            cell.frame.size.height = 0
            
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
            //cell.layoutIfNeeded()
            //tableView.layoutSubviews()
            return cell
        } else {
            return ConversationCell()
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if !cellHeights.keys.contains(indexPath.row) {
//            cellHeights[indexPath.row] = cell.frame.height
//        }
//        //cellHeights.append(cell.frame.height)
//        //print("\(indexPath.row): \(cellHeights)")
//    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        //print(cellHeights[indexPath.row])
//        if let height = cellHeights[indexPath.row] {
//            //print("AAAAAA: \(indexPath.row)")
//            return height
//        }
//        //print("WWWWWWWWW: \(indexPath.row)")
//        return UITableViewAutomaticDimension
//    }
    
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
            //print("hi")
            textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height + 10
            self.tableView.contentInset = UIEdgeInsetsMake(10, 0, keyboardHeight + textViewContainerHeightConstraint.constant, 0)
        } else {
            //print("bye")
            
            if textView.intrinsicContentSize.height < textViewContainerHeightConstraint.constant {
                //print("maybe")
                textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height
            }
            
            //textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height
            textView.isScrollEnabled = true
            //textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height
        }
        
//        if textInputViewToHeader.constant + 10 < 100 {
//            print("reached")
//            return
//            //textInputViewToHeader.constant = 5
//            //textView.isScrollEnabled = true
//        }
        
        //textView.sizeToFit()
        
        
//        if let font = textView.font {
//            //            print(textView.contentSize.height)
//            //            print(font.lineHeight)
//            //            print(textView.contentSize.height / font.lineHeight)
//            
//            if textView.contentSize.height / font.lineHeight >= 5 {
//                //print("yoooooo")
//                textView.isScrollEnabled = true
//                textView.showsVerticalScrollIndicator = false
//                return
//            }
//        }
//        textViewContainerHeightConstraint.constant = textView.intrinsicContentSize.height + 10
        
        //self.tableView.contentInset = UIEdgeInsetsMake(10, 0, keyboardHeight + textViewContainerHeightConstraint.constant, 0)
        //print(keyboardHeight + textViewContainerHeightConstraint.constant)
        //self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
        UIView.animate(withDuration: 0.25) {
            //print("hey")
            self.view.layoutIfNeeded()
        }
        
        
        //tableView.contentInset = UIEdgeInsetsMake(10, 0, keyboardHeight - 50, 0)
        
        //        if self.messagesArr.count > 0 {
        //            self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
        //            //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
        //        }
        
        
        //print(textInputView.frame.height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        
//        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        
//        let bottomOffset = CGPoint(x: 0, y: tableView.bounds.size.height - tableView.contentSize.height)
//        tableView.setContentOffset(bottomOffset, animated: true)
        
        //        if self.messagesArr.count > 0 {
        //            self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
        //            //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
        //        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //print("hi")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            textViewContainerBottomConstraint.constant = keyboardSize.height - 50
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            
            UIView.animate(withDuration: 1) {
                //print("hey")
                self.view.layoutIfNeeded()
            }
            
            return
            
//            if tableView.visibleCells.isEmpty {
//                print("hi")
//                self.textViewContainerBottomConstraint.constant = keyboardSize.height - 50
//                UIView.animate(withDuration: 1) {
//                    //print("hey")
//                    self.view.layoutIfNeeded()
//                }
//            } else if (tableView.visibleCells.last?.frame.origin.y)! + (tableView.visibleCells.last?.frame.height)! > keyboardSize.origin.y - 50 {
//                print("bye")
//                //print("hi")
//                if self.tableView.frame.origin.y == 65 {
//                    
//                    
//                    self.textViewContainerBottomConstraint.constant = keyboardSize.height - 50
//                    //self.tableViewBottomConstraint.constant = keyboardSize.height
//                    
//                    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, keyboardSize.height - 50, 0)
//                    self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
//                    UIView.animate(withDuration: 1) {
//                        //print("hey")
//                        self.view.layoutIfNeeded()
//                    }
//                    
//                    //self.tableView.frame.origin.y -= keyboardSize.height - 50 - textInputView.frame.height
//                    //self.tableViewBottomConstraint.constant = 2
//                    //self.textInputView.frame.origin.y -= keyboardSize.height - 50
//                    //self.footerView.frame.origin.y -= keyboardSize.height - 50
//                    //print(textView.frame.origin)
//                }
//            } else {
//                print("last")
//                self.textViewContainerBottomConstraint.constant = keyboardSize.height - 50
//                UIView.animate(withDuration: 1) {
//                    //print("hey")
//                    self.view.layoutIfNeeded()
//                }
//                //self.textInputView.frame.origin.y -= keyboardSize.height - 50
//                //self.footerView.frame.origin.y -= keyboardSize.height - 50
//            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //if self.tableView.frame.origin.y != 75 {
        //print("bye")
        //self.tableView.frame.origin.y = 65
        self.textViewContainerBottomConstraint.constant = 0
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        
        UIView.animate(withDuration: 1) {
            //print("hey")
            self.view.layoutIfNeeded()
        }
        //self.textInputView.frame.origin.y = 569
        //self.footerView.frame.origin.y = 617
        //}
        //}
    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //
    //        let contentSize = self.textView.sizeThatFits(self.textView.bounds.size)
    //        var frame = self.textView.frame
    //        frame.size.height = contentSize.height
    //        self.textView.frame = frame
    //
    //        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.textView, attribute: .height, relatedBy: .equal, toItem: self.textView, attribute: .width, multiplier: textView.bounds.height/textView.bounds.width, constant: 1)
    //        self.textView.addConstraint(aspectRatioTextViewConstraint)
    //    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        guard let messageContent = textView.text, messageContent != "" else {
            return
        }
        
        //keep text not sent, show typing, shrinks text box when sending large message
        
        if let messageContent = textView.text {
            //print("JAKE: \(messageContent)")
            if let user = Auth.auth().currentUser {
                let userId = user.uid
                let key = DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").childByAutoId().key
                //let key = DataService.ds.REF_BASE.child("status").childByAutoId().key
                let message = ["content": messageContent,
                               "timestamp": ServerValue.timestamp(),
                               "senderuid": userId] as [String : Any]
                //let childUpdates = ["/status/\(key)": status,
                // "/users/\(userId)/statusId/\(key)/": true] as Dictionary<String, Any>
                //print("JAKE: \(childUpdates)")
                //if user[selecteduser] = false messages/user = true
                //store text if not sent in field
                //read and typing
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").updateChildValues([key : message, selectedProfile.usersKey : false, userId : true])
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/details").updateChildValues(["lastMsgContent" : messageContent, "lastMsgDate" : ServerValue.timestamp()])
                //DataService.ds.REF_CONVERSATION.child("\(conversationUid)/users").updateChildValues([userId : true,selectedProfile.usersKey : true])
                DataService.ds.REF_USERS.child(selectedProfile.usersKey).updateChildValues(["hasNewMsg" : true])
                //DataService.ds.REF_BASE.updateChildValues(childUpdates)
                textView.text = ""
                placeholderLabel.isHidden = false
//                if self.messagesArr.count > 0 {
//                    self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
//                    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
//                    //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
//                }
//                textView.text = ""
//                placeholderLabel.isHidden = false
                textViewContainerHeightConstraint.constant = 48
//                if let lineHeight = textView.font?.lineHeight {
//                    //print(lineHeight)
//                    textView.contentSize.height = lineHeight
//                }
                //print(messagesArr.count)
                //set back to normal textview
                //textView.frame.height = textView.intrinsicContentSize.height
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conversationToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                if originController == "feedToViewProfile" {
                    nextVC.originController = "feedToViewProfile"
                    nextVC.selectedProfile = sender as? Users
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "searchToViewProfile" {
                    nextVC.originController = "searchToViewProfile"
                    nextVC.selectedProfile = sender as? Users
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "joinedListToViewProfile" {
                    nextVC.originController = "joinedListToViewProfile"
                    nextVC.selectedProfile = sender as? Users
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                } else if originController == "joinedFriendsToViewProfile" {
                    nextVC.originController = "joinedFriendsToViewProfile"
                    nextVC.selectedStatus = selectedStatus
                    nextVC.selectedProfile = sender as? Users
                    nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                }
                nextVC.selectedProfile = sender as? Users
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
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(messagesArr.count)
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //print(lastMsgDate)
                //print(currentConversation.messages)
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
                //}
            }
            
            let selectedUser = self.selectedProfile
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedUser)
            
        } else if originController == "feedToViewProfile" {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(messagesArr.count)
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //print(lastMsgDate)
                //print(currentConversation.messages)
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
                //}
            }
            
            let selectedUser = self.selectedProfile
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedUser)
        } else if originController == "searchToViewProfile" {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(messagesArr.count)
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //print(lastMsgDate)
                //print(currentConversation.messages)
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
                //}
            }
            
            let selectedUser = self.selectedProfile
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedUser)
        } else if originController == "joinedListToViewProfile" {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(messagesArr.count)
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //print(lastMsgDate)
                //print(currentConversation.messages)
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
                //}
            }
            
            let selectedUser = self.selectedProfile
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedUser)
        } else if originController == "friendsListToConversation" {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(currentConversation.details["lastMsgDate"])
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
            }
            
            performSegue(withIdentifier: "conversationToFriendsList", sender: nil)
            
        } else if originController == "joinedFriendsToViewProfile" {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(currentConversation.details["lastMsgDate"])
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
            }
            
            performSegue(withIdentifier: "conversationToViewProfile", sender: selectedProfile)
            
        }
            
        else {
            if let currentUser = Auth.auth().currentUser?.uid {
                //print(currentConversation)
                //print(messagesArr.count)
                //if let lastMsgDate = currentConversation.details["lastMsgDate"] as? String {
                //print(lastMsgDate)
                //print(currentConversation.messages)
                //if lastMsgDate == "" {
                if messagesArr.count == 0 {
                    DataService.ds.REF_CONVERSATION.child(currentConversation.conversationKey).removeValue()
                    DataService.ds.REF_USERS.child(currentUser).child("conversationId").child(currentConversation.conversationKey).removeValue()
                }
                //}
            }
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "conversationToMyProfile", sender: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}
