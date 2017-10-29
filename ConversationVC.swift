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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
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
        
        self.conversationUid = "uid3"
        
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
        //selecting on messages
        //get conversation id
        //time not duration
        //initializing data (initializer uid)
        //writing data
        //load table bottome up, or automatically place scroll position to bottom
        //add placeholder text
        //grow textview input
        //autosizing view using >= lbl width
        //translate table up if pressed or down if scrolling
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messagesArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as? ConversationCell {
            //cell.configureCell(conversation: conversation, users: users)
            //cell.selectionStyle = .none
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 120
            cell.configureCell(message: message)
            if messagesArr.endIndex - 1 == indexPath.row {
                if let currentUser = Auth.auth().currentUser?.uid {
                    if message.senderuid == currentUser {
                        cell.sentMsgAgeLbl.text = "Sent \(cell.configureTimeAgo(unixTimestamp: message.timestamp))"
                    } else {
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
                //DataService.ds.REF_BASE.updateChildValues(childUpdates)
                textView.text = ""
                
            }
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
    }
    
    
}
