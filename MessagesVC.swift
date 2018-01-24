//
//  MessagesVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var headerView: CustomHeader!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    
    var usersArr = [Users]()
    var userKeys = [String]()
    var conversationArr = [Conversation]()
    var newMsgKeyArr = [String]()
    var filtered = [Users]()
    var originController = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        tableView.keyboardDismissMode = .onDrag
        
        
        DataService.ds.REF_CONVERSATION.queryOrdered(byChild: "/details/lastMsgDate").observe(.value, with: { (snapshot) in
            
            self.conversationArr = []
            self.filtered = []
            self.usersArr = []
            self.userKeys = []
            
            if let currentUser = Auth.auth().currentUser?.uid {
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        
                        if let conversationDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                            
                            let userConversation = conversation.users.keys.contains(currentUser)
                            
                            if userConversation && conversation.users[currentUser] as? Bool == true {
                                for users in conversation.users {
                                    if users.key != currentUser {
                                        self.userKeys.insert(users.key, at: 0)
                                    }
                                }
                                self.conversationArr.insert(conversation, at: 0)
                                
                                if let unread = conversation.messages[currentUser] as? Bool {
                                    if unread == false {
                                        self.newMsgKeyArr.insert(conversation.conversationKey, at: 0)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if self.conversationArr.count == 0 {
                self.tableView.reloadData()
            }
            self.loadUsers()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if originController == "conversationToMessages" {
            tableView.frame.origin.x -= 500
            tableView.isHidden = false
            searchBar.frame.origin.x -= 500
            searchBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame.origin.x += 500
                self.searchBar.frame.origin.x += 500
            }
        } else {
            tableView.isHidden = false
            searchBar.isHidden = false
            return
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = conversationArr
        let users = filtered[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell") as? MessagesCell {
            
            cell.configureCell(conversation: conversation, users: users)
            
            cell.selectionStyle = .none
            return cell
        } else {
            return MessagesCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //need correct selection
        DataService.ds.REF_CONVERSATION.child("\(conversationArr[indexPath.row].conversationKey)/messages").updateChildValues(["read" : true])
        let selectedConversation = conversationArr[indexPath.row].conversationKey
        if newMsgKeyArr.count == 1 {
            if newMsgKeyArr[0] == conversationArr[indexPath.row].conversationKey {
                if let currentUser = Auth.auth().currentUser?.uid {
                    DataService.ds.REF_USERS.child(currentUser).updateChildValues(["hasNewMsg" : false])
                }
            }
        }
        performSegue(withIdentifier: "messagesToConversation", sender: selectedConversation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let muteAction = UITableViewRowAction(style: .normal, title: " Mute  ") { (rowAction, indexPath) in
            
            if let currentUser = Auth.auth().currentUser?.uid {
                
                let mutedUserKey = self.filtered[indexPath.row].usersKey
                for convo in self.conversationArr {
                    if convo.users.keys.contains(mutedUserKey) {
                        DataService.ds.REF_CONVERSATION.child(convo.conversationKey).child("users").updateChildValues([currentUser : false])
                        break
                    }
                }
                
            }
            
        }
        muteAction.backgroundColor = UIColor.red
        
        return [muteAction]
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = usersArr.filter({ (user) -> Bool in
            if searchText == "" {
                return true
            } else {
                
                let nameCheck = user.name as NSString
                let nameRange = nameCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return nameRange.location != NSNotFound
            }
            
            
        })
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messagesToConversation" {
            if let nextVC = segue.destination as? ConversationVC {
                nextVC.conversationUid = sender as! String
            }
        } else if segue.identifier == "messagesToFeed" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "messagesToFeed"
            }
        } else if segue.identifier == "messagesToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "messagesToMyProfile"
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.searchBar.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToFeed", sender: nil)
        }
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.searchBar.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToFeed", sender: nil)
        }
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.searchBar.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToJoinedList", sender: nil)
        }
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.searchBar.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToSearch", sender: nil)
        }
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.75) {
            self.footerView.frame.origin.y += 3000
            self.tableView.frame.origin.y += 3000
            self.searchBar.frame.origin.y += 3000
            self.headerView.frame.origin.y += 3000
        }
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToMyProfile", sender: nil)
        }
    }
    
    func loadUsers() {
        
        self.usersArr = []
        
        for userKey in userKeys {
            
            DataService.ds.REF_USERS.child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let usersDict = snapshot.value as? Dictionary<String, Any> {
                    let key = snapshot.key
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
                            
                        }
                    }
                    self.usersArr.append(users)
                    
                }
                self.filtered = self.usersArr
                self.tableView.reloadData()
            })
        }
        
    }
}
