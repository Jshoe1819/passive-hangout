//
//  JoinedFriendsVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/7/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JoinedFriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, JoinedProfilesListCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    var usersArr = [Users]()
    var filtered = [Users]()
    var selectedStatus: Status!
    var currentUserInfo: Users!
    var selectedUser: Users!
    var originController = ""
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
                                
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                                
                                self.currentUserInfo = users
                            }
                        }
                        let userJoinedSelected = users.joinedList.keys.contains { (key) -> Bool in
                            key == self.selectedStatus.statusKey
                        }
                        if userJoinedSelected {
                            self.usersArr.append(users)
                        }
                    }
                }
                self.filtered = self.usersArr
            }
            if self.usersArr.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame.origin.x += 500
        tableView.isHidden = false
        searchBar.frame.origin.x += 500
        searchBar.isHidden = false
        isEmptyImg.frame.origin.x += 500
        
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x -= 500
            self.searchBar.frame.origin.x -= 500
            self.isEmptyImg.frame.origin.x -= 500
        }
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
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        if filtered.count == 0 {
//            print("empty, show label or img")
//        }
        return filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let users = filtered[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "joinedProfilesListCell", for: indexPath) as? JoinedProfilesListCell {
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            cell.configureCell(users: users, currentUser: currentUserInfo)
            return cell
            
        } else {
            return JoinedProfilesListCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to view profile
        //origin controller and selected profile
        let selectedProfile = filtered[indexPath.row]
        performSegue(withIdentifier: "joinedFriendsToViewProfile", sender: selectedProfile)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinedFriendsToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                nextVC.originController = "joinedFriendsToViewProfile"
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                nextVC.selectedStatus = selectedStatus
            }
        } else if segue.identifier == "joinedFriendsToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "joinedFriendsToHome"
            }
        } else if segue.identifier == "joinedListToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "joinedListToMyProfile"
            }
        } else if segue.identifier == "joinedFriendsToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "joinedFriendsToJoinedList"
            }
        } else if segue.identifier == "joinedFriendsToPastStatuses" {
            if let nextVC = segue.destination as? PastStatusesVC {
                nextVC.originController = "joinedFriendsToPastStatuses"
            }
        } else if segue.identifier == "joinedFriendsToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "joinedFriendsToSearch"
            }
        }
    }
    
    func didPressAddFriendBtn(_ tag: Int) {
        //print("a \(tag)")
        let friendKey = filtered[tag].usersKey
            DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").updateChildValues([friendKey: "sent"])
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUserInfo.usersKey: "received"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues(["seen": "false"])
        
    }
    
    func didPressRequestSentBtn(_ tag: Int) {
        //print("r \(tag)")
        let friendKey = filtered[tag].usersKey
            DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").child(friendKey).removeValue()
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUserInfo.usersKey).removeValue()
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if originController == "myProfileToJoinedFriends" {
            performSegue(withIdentifier: "joinedFriendsToMyProfile", sender: nil)
        }
        performSegue(withIdentifier: "joinedFriendsToPastStatuses", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedFriendsToHome", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedFriendsToJoinedList", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedFriendsToSearch", sender: nil)
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedFriendsToMyProfile", sender: nil)
    }
    
    func refresh(sender: Any) {
        
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
                                self.currentUserInfo = users
                            }
                        }
                        let userJoinedSelected = users.joinedList.keys.contains { (key) -> Bool in
                            key == self.selectedStatus.statusKey
                        }
                        if userJoinedSelected {
                            self.usersArr.append(users)
                        }
                    }
                }
                self.filtered = self.usersArr
            }
            if self.usersArr.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
            self.tableView.reloadData()
        })
        
//        if originController == "viewProfileToPastStatuses" || originController == "joinedListToViewProfile" || originController == "feedToViewProfile" || originController == "joinedFriendsToViewProfile" || originController == "searchToViewProfile" {
//            profilePicImg.isHidden = false
//            populateProfilePicture(user: viewedProfile)
//        }
//        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //            if self.statusArr.count == 0 {
            //                self.isEmptyImg.isHidden = false
            //            } else {
            //                self.isEmptyImg.isHidden = true
            //            }
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
        
        
    }
    
    
}
