//
//  FriendsListVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/27/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsListVC: UIViewController, FriendsListCellDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var opaqueBackground: UIButton!
    @IBOutlet weak var removeFriendView: RoundedPopUp!
    @IBOutlet weak var removeFriendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    var usersArr = [Users]()
    var conversationArr = [Conversation]()
    var currentFriendsList = Dictionary<String, Any>()
    var selectedProfile: Int!
    var filtered = [Users]()
    var originController = ""
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        refreshControl.addTarget(self, action: #selector(FriendsListVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        tableView.keyboardDismissMode = .onDrag
        
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value {
                            self.currentFriendsList.updateValue(value, forKey: snap.key)
                            
                        }
                    }
                }
            })
        }
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if users.usersKey == currentUser {
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                            }
                        }
                        
                        if self.currentFriendsList.keys.contains(users.usersKey) {
                            if self.currentFriendsList[users.usersKey] as! String == "received" {
                                self.usersArr.insert(users, at: 0)
                            }
                            else {
                                self.usersArr.append(users)
                            }
                        }
                        
                    }
                }
                self.filtered = self.usersArr
            }
            
            if self.usersArr.count == 0 {
                self.isEmptyImg.isHidden = false
                UIView.animate(withDuration: 0.75) {
                    self.isEmptyImg.alpha = 1.0
                }
            } else {
                self.isEmptyImg.isHidden = true
                self.isEmptyImg.alpha = 0.0
            }
            
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_CONVERSATION.queryOrdered(byChild: "/details/lastMsgDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.conversationArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let conversationDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            let userConversation = conversation.users.keys.contains(currentUser)
                            if userConversation {
                                self.conversationArr.insert(conversation, at: 0)
                            }
                        }
                    }
                }
            }
            
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if originController == "" {
            
            searchBar.frame.origin.x += 500
            searchBar.isHidden = false
            tableView.frame.origin.x += 500
            tableView.isHidden = false
            isEmptyImg.frame.origin.x += 500
            
            UIView.animate(withDuration: 0.25) {
                
                self.searchBar.frame.origin.x -= 500
                self.tableView.frame.origin.x -= 500
                self.isEmptyImg.frame.origin.x -= 500
                
            }
            
        } else {
            
            searchBar.frame.origin.x -= 500
            searchBar.isHidden = false
            tableView.frame.origin.x -= 500
            tableView.isHidden = false
            isEmptyImg.frame.origin.x -= 500
            
            UIView.animate(withDuration: 0.25) {
                
                self.searchBar.frame.origin.x += 500
                self.tableView.frame.origin.x += 500
                self.isEmptyImg.frame.origin.x += 500
                
            }
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = usersArr.filter({ (user) -> Bool in
            if searchText == "" {
                return true
            } else {
                
                let nameCheck = user.name as NSString
                let nameRange = nameCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                let cityCheck = user.currentCity as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return nameRange.location != NSNotFound || cityRange.location != NSNotFound
            }
            
        })
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let users = filtered[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "friendsListCell", for: indexPath) as? FriendsListCell {
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            
            cell.configureCell(friendsList: currentFriendsList, users: users)
            
            return cell
            
        } else {
            return FriendsListCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProfileKey = usersArr[indexPath.row].usersKey
        performSegue(withIdentifier: "friendsListToViewProfile", sender: selectedProfileKey)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Remove") { (rowAction, indexPath) in
            
            self.selectedProfile = indexPath.row
            self.removeFriendView.frame.origin.y += 1000
            self.removeFriendView.isHidden = false
            self.opaqueBackground.isHidden = false
            
            UIView.animate(withDuration: 0.25) {
                self.removeFriendView.frame.origin.y -= 1000
            }
            
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Message") { (rowAction, indexPath) in
            tableView.setEditing(true, animated: true)
            if tableView.isEditing == true {
                
                for index in 0..<self.conversationArr.count {
                    if self.conversationArr[index].users.keys.contains(self.usersArr[indexPath.row].usersKey) {
                        let selectedConversation = self.conversationArr[index].conversationKey
                        self.performSegue(withIdentifier: "friendsListToConversation", sender: selectedConversation)
                        return
                    }
                    
                }
                
                if let user = Auth.auth().currentUser {
                    
                    let userId = user.uid
                    if self.usersArr[indexPath.row].isPrivate && self.usersArr[indexPath.row].friendsList[userId] as? String != "friends" {
                        return
                    }
                    
                    let key = DataService.ds.REF_BASE.child("conversations").childByAutoId().key
                    let conversation = ["details": ["lastMsgContent":"","lastMsgDate":""],
                                        "messages": ["a": true],
                                        "users": [userId: true,
                                                  self.usersArr[indexPath.row].usersKey: true]] as [String : Any]
                    
                    let childUpdates = ["/conversations/\(key)": conversation,
                                        "/users/\(userId)/conversationId/\(key)/": true] as Dictionary<String, Any>
                    DataService.ds.REF_BASE.updateChildValues(childUpdates)
                    self.performSegue(withIdentifier: "friendsListToConversation", sender: key)
                }
                
                self.tableView.reloadData()
                
            }
            
        }
        
        editAction.backgroundColor = UIColor(red:0.64, green:0.84, blue:0.64, alpha:1)
        
        return [deleteAction, editAction]
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendsListToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfileKey = sender as! String
            }
        } else if segue.identifier == "friendsListToConversation" {
            if let nextVC = segue.destination as? ConversationVC {
                nextVC.conversationUid = sender as! String
                nextVC.originController = "friendsListToConversation"
            }
        } else if segue.identifier == "friendsListToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "friendsListToHome"
            }
        } else if segue.identifier == "friendsListToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "friendsListToMyProfile"
            }
        } else if segue.identifier == "friendsListToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "friendsListToJoinedList"
            }
        } else if segue.identifier == "friendsListToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "friendsListToSearch"
            }
        }
    }
    
    func didPressAcceptBtn(_ tag: Int) {
        
        let friendKey = usersArr[tag].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues([friendKey: "friends"])
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUser: "friends"])
        }
        self.refresh(sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    
    func didPressIgnoreBtn(_ tag: Int) {
        
        let friendKey = usersArr[tag].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
        }
        self.refresh(sender: self)
    }
    @IBAction func removeFriendBtnPressed(_ sender: Any) {
        
        let friendKey = self.usersArr[selectedProfile].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
        }
        
        opaqueBackground.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.removeFriendView.frame.origin.y += 1000
        }
        
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.removeFriendView.isHidden = true
            self.removeFriendView.frame.origin.y -= 1000
        }
        
        self.refresh(sender: self)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        opaqueBackground.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.removeFriendView.frame.origin.y += 1000
        }
        
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.removeFriendView.isHidden = true
            self.removeFriendView.frame.origin.y -= 1000
        }
        tableView.reloadData()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToMyProfile", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToHome", sender: nil)
    }
    
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToJoinedList", sender: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToMyProfile", sender: nil)
    }
    
    @objc func refresh(sender: Any) {
        
        self.isEmptyImg.isHidden = true
        self.isEmptyImg.alpha = 0.0
        
        self.currentFriendsList.removeAll()
        self.filtered = []
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value {
                            self.currentFriendsList.updateValue(value, forKey: snap.key)
                        }
                    }
                }
            })
            
        }
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if self.currentFriendsList.keys.contains(users.usersKey) {
                            if self.currentFriendsList[users.usersKey] as! String == "received" {
                                self.usersArr.insert(users, at: 0)
                            }
                            else {
                                self.usersArr.append(users)
                            }
                        }
                        
                    }
                }
                self.filtered = self.usersArr
            }
            self.tableView.reloadData()
        })
        
        if self.usersArr.count == 0 {
            self.isEmptyImg.isHidden = false
            UIView.animate(withDuration: 0.75) {
                self.isEmptyImg.alpha = 1.0
            }
        } else {
            self.isEmptyImg.isHidden = true
            self.isEmptyImg.alpha = 0.0
        }
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            self.refreshControl.endRefreshing()
        }
    }
    
}
