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
    var messagesArr = [Messages]()
    var currentConversation: Conversation!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var textInputView: ReceiverMessageColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
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
        
        DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
            
            self.messagesArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("Messages: \(snap)")
                    if let messageDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let message = Messages(messageKey: key, messageData: messageDict)
                        self.messagesArr.append(message)
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        DataService.ds.REF_CONVERSATION.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("Conversation: \(snap)")
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
        
        //hooking up button segues
        //get conversation id
        //time not duration
        //initializing data (initializer uid)
        //insert at 0, reverse array, scroll to bottom
        //grow textview input
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                                    //self.footerNewFriendIndicator.isHidden = false
                                }
                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
                                    value as? String == "false"
                                }
                                if newJoin {
                                    //self.footerNewFriendIndicator.isHidden = false
                                }
                            }
                            let otherUser = self.currentConversation.users.keys.contains(users.usersKey) && users.usersKey != currentUser
                            if otherUser {
                                self.nameLbl.text = users.name
                                self.populateProfilePicture(user: users)
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
        
        if self.messagesArr.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
            //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
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
            
            cell.configureCell(message: message)
            
            if messagesArr.endIndex - 1 == indexPath.row {
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
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.tableView.frame.origin.y == 65 {
                self.tableView.frame.origin.y -= keyboardSize.height - 50
                self.textInputView.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if self.tableView.frame.origin.y != 65 {
            self.tableView.frame.origin.y = 65
            self.textInputView.frame.origin.y = 572
        }
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        guard let messageContent = textView.text, messageContent != "" else {
            return
        }
        
        if let messageContent = textView.text {
            print("JAKE: \(messageContent)")
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
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/messages").updateChildValues([key : message])
                DataService.ds.REF_CONVERSATION.child("\(conversationUid)/details").updateChildValues(["lastMsgContent" : messageContent, "lastMsgDate" : ServerValue.timestamp()])
                //DataService.ds.REF_BASE.updateChildValues(childUpdates)
                if self.messagesArr.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item:self.messagesArr.count-1, section: 0), at: .bottom, animated: true)
                    //self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
                }
                textView.text = ""
            }
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "conversationToMessages", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "conversationToFeed", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "conversationToJoinedList", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "conversationToSearch", sender: nil)
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "conversationToMyProfile", sender: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
}
