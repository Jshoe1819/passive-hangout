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
    
    var usersArr = [Users]()
    var conversationArr = [Conversation]()
    var currentFriendsList = Dictionary<String, Any>()
    var tappedBtnTags = [Int]()
    var deleted = [Int]()
    var filtered = [Users]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = UIColor.purple
        refreshControl.addTarget(self, action: #selector(ActivityFeedVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchBar.keyboardAppearance = .dark
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
                    //print("USERS: \(snap)")
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
            
            if self.currentFriendsList.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
            
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_CONVERSATION.queryOrdered(byChild: "/details/lastMsgDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.conversationArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("Conversation: \(snap)")
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
            //change to explore.reload
            //            for index in 0..<self.conversationArr.count {
            //                if let lastMsgDate = self.conversationArr[index].details["lastMsgDate"] {
            //            print(lastMsgDate)
            //                }
            //            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //        if(filtered.count == 0){
        //            searchActive = false
        //        } else {
        //            searchActive = true;
        //        }
        
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
            
            if deleted.contains(indexPath.row) {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            
            if tappedBtnTags.count > 0 {
                cell.menuBtn.isEnabled = false
            } else {
                cell.menuBtn.isEnabled = true
            }
            
            cell.configureCell(friendsList: currentFriendsList, users: users)
            
            return cell
            
        } else {
            return FriendsListCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProfile = usersArr[indexPath.row]
        performSegue(withIdentifier: "friendsListToViewProfile", sender: selectedProfile)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendsListToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
            }
        } else if segue.identifier == "friendsListToConversation" {
            if let nextVC = segue.destination as? ConversationVC {
                nextVC.conversationUid = sender as! String
                nextVC.originController = "friendsListToConversation"
            }
        }
    }
    
    func didPressMenuBtn(_ tag: Int) {
        
        tappedBtnTags.append(tag)
        tableView.reloadData()
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Remove Friend", style: UIAlertActionStyle.destructive, handler: { action in
            // create the alert
            let alert = UIAlertController(title: "Remove Friend", message: "Are you sure you would like to remove this friend from your list?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.destructive, handler: { action in
                let friendKey = self.usersArr[tag].usersKey
                if let currentUser = Auth.auth().currentUser?.uid {
                    DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
                    DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
                    self.deleted.append(tag)
                    self.tableView.reloadData()
                }
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                
                self.tappedBtnTags.removeAll()
                self.tableView.reloadData()
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Send Message", style: UIAlertActionStyle.default, handler: { action in
            
            //perform segue
            for index in 0..<self.conversationArr.count {
                if self.conversationArr[index].users.keys.contains(self.usersArr[tag].usersKey) {
                    let selectedConversation = self.conversationArr[index].conversationKey
                    self.performSegue(withIdentifier: "friendsListToConversation", sender: selectedConversation)
                    return
                }
                //print("hi")
            }
            //print("out")
            if let user = Auth.auth().currentUser {
                let userId = user.uid
                let key = DataService.ds.REF_BASE.child("conversations").childByAutoId().key
                let conversation = ["details": ["lastMsgContent":"","lastMsgDate":""],
                                    "messages": ["a": true],
                                    "users": [userId: true,
                                              self.usersArr[tag].usersKey: true]] as [String : Any]
                
                let childUpdates = ["/conversations/\(key)": conversation,
                                    "/users/\(userId)/conversationId/\(key)/": true] as Dictionary<String, Any>
                DataService.ds.REF_BASE.updateChildValues(childUpdates)
                self.performSegue(withIdentifier: "friendsListToConversation", sender: key)
            }
            
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "View Profile", style: UIAlertActionStyle.default, handler: { action in
            
            //perform segue
            let selectedProfile = self.usersArr[tag]
            
            self.performSegue(withIdentifier: "friendsListToViewProfile", sender: selectedProfile)
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func didPressAcceptBtn(_ tag: Int) {
        
        let friendKey = usersArr[tag].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues([friendKey: "friends"])
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUser: "friends"])
            tableView.reloadData()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if deleted.contains(indexPath.row) {
            return 0
        } else {
            return 84
        }
    }
    
    
    func didPressIgnoreBtn(_ tag: Int) {
        
        let friendKey = usersArr[tag].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").child(friendKey).removeValue()
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUser).removeValue()
            deleted.append(tag)
            tableView.reloadData()
        }
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
    
    func refresh(sender: Any) {
        
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
                    //print("USERS: \(snap)")
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
        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.currentFriendsList.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
    }
    
}
