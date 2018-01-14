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
    
    var usersArr = [Users]()
    var conversationArr = [Conversation]()
    var searchResults = [Users]()
    var newMsgKeyArr = [String]()
    //    var currentUser: Users!
    
    @IBOutlet weak var headerView: CustomHeader!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        tableView.keyboardDismissMode = .onDrag
        
        
        DataService.ds.REF_CONVERSATION.queryOrdered(byChild: "/details/lastMsgDate").observe(.value, with: { (snapshot) in
            
            self.conversationArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("Conversation: \(snap)")
                    if let conversationDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            let userConversation = conversation.users.keys.contains(currentUser)
                            if userConversation && conversation.users[currentUser] as? Bool == true {
                                self.conversationArr.insert(conversation, at: 0)
                                if let unread = conversation.messages[currentUser] as? Bool {
                                    if unread == false {
                                        self.newMsgKeyArr.insert(conversation.conversationKey, at: 0)
                                        print(self.newMsgKeyArr)
                                    }
                                }
                                //self.newMsgDict[conversation.conversationKey] = conversation.messages["\(currentUser)"] as? Bool
                            }
                        }
                    }
                }
            }
            //change to explore.reload
            //            for index in 0..<self.conversationArr.count {
            //                if let lastMsgDate = self.conversationArr[index].details["lastMsgDate"] {
            //            print(lastMsgDate)
            //                }
            //            }
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
                                //self.currentUser = users
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
                self.searchResults = self.usersArr
            }
            self.tableView.reloadData()
        })
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = conversationArr[indexPath.row]
        let users = searchResults
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell") as? MessagesCell {
            
            cell.configureCell(conversation: conversation, users: users)
            
            //            let userDeleted = !currentUser.conversationId.keys.contains(conversation.conversationKey)
            //
            //            if userDeleted {
            //                cell.isHidden = true
            //            }
            
            cell.selectionStyle = .none
            return cell
        } else {
            return MessagesCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            //print(indexPath.row)
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_CONVERSATION.child(conversationArr[indexPath.row].conversationKey).child("users").updateChildValues([currentUser : false])
            }
            
            
            //delete conversation from user node
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchResults = usersArr.filter({ (user) -> Bool in
            
            if searchText == "" {
                return true
            }
            
            let nameCheck = user.name as NSString
            let contentRange = nameCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            
            return contentRange.location != NSNotFound
            
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
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
        let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "messagesToMyProfile", sender: nil)
        }
    }
}
