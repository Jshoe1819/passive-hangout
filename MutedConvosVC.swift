//
//  MutedConvosVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 1/27/18.
//  Copyright © 2018 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MutedConvosVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MutedConvosDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    var usersArr = [Users]()
    var conversationArr = [Conversation]()
    var conversationKeys = [String]()
    var unmutedUserKeys = [String]()
    var unmutedConversationKeys = [String]()
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
        refreshControl.addTarget(self, action: #selector(ActivityFeedVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        tableView.keyboardDismissMode = .onDrag
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("conversationId").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        self.conversationKeys.append(snap.key)
                    }
                }
                self.refresh(sender: self)
            })
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let users = filtered[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mutedConversationCell", for: indexPath) as? MutedConvosCell {
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            
            
            
            cell.configureCell(users: users)
            
            if unmutedUserKeys.contains(users.usersKey) {
                cell.mutedSwitch.isOn = false
            }
            
            return cell
            
        } else {
            return MutedConvosCell()
        }
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
    
    func mutedSwitchOn(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            for conversation in conversationArr {
                if conversation.users.keys.contains(filtered[tag].usersKey) {
                    DataService.ds.REF_CONVERSATION.child("\(conversation.conversationKey)/users").updateChildValues([currentUser : false])
                    for index in 0..<unmutedUserKeys.count {
                        if unmutedUserKeys[index] == filtered[tag].usersKey {
                            unmutedUserKeys.remove(at: index)
                        }
                        
                    }
                }
            }
        }
    }
    func mutedSwitchOff(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            for conversation in conversationArr {
                if conversation.users.keys.contains(filtered[tag].usersKey) {
                    DataService.ds.REF_CONVERSATION.child("\(conversation.conversationKey)/users").updateChildValues([currentUser : true])
                    unmutedConversationKeys.append(conversation.conversationKey)
                    unmutedUserKeys.append(filtered[tag].usersKey)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mutedConvosToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "mutedConvosToHome"
            }
        } else if segue.identifier == "mutedConvosToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "mutedConvosToJoinedList"
            }
        } else if segue.identifier == "mutedConvosToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "mutedConvosToSearch"
            }
        } else if segue.identifier == "mutedConvosToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "mutedConvosToMyProfile"
            }
        }
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "mutedConvosToHome", sender: nil)
    }
    @IBAction func joinedBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "mutedConvosToJoinedList", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "mutedConvosToSearch", sender: nil)
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "mutedConvosToMyProfile", sender: nil)
    }
    
    func refresh(sender: Any) {
        
        isEmptyImg.isHidden = true
        isEmptyImg.alpha = 0.0
        searchBar.text = ""
        self.conversationArr = []
        self.usersArr = []
        self.filtered = []
        self.unmutedUserKeys = []
        
        for convo in conversationKeys {
            
            DataService.ds.REF_CONVERSATION.child(convo).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let conversationDict = snapshot.value as? Dictionary<String, Any> {
                    let key = snapshot.key
                    let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                    self.conversationArr.append(conversation)
                    if let currentUser = Auth.auth().currentUser?.uid {
                        
                        if let user = conversation.users[currentUser] as? Bool {
                            if user == false {
                                
                                for users in conversation.users.keys {
                                    if users != currentUser {
                                        DataService.ds.REF_USERS.child(users).observeSingleEvent(of: .value, with: { (snapshot) in
                                            
                                            if let usersDict = snapshot.value as? Dictionary<String, Any> {
                                                let key = snapshot.key
                                                let users = Users(usersKey: key, usersData: usersDict)
                                                self.usersArr.append(users)
                                                self.filtered = self.usersArr
                                            }
                                            self.tableView.reloadData()
                                            
                                        })
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            })
            
        }
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.usersArr.count == 0 {
                self.isEmptyImg.isHidden = false
                UIView.animate(withDuration: 0.75) {
                    self.isEmptyImg.alpha = 1.0
                }
            }
            self.refreshControl.endRefreshing()
        }
        
        
    }
    
    
}
