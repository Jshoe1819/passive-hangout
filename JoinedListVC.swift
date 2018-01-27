//
//  JoinedListVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/30/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class JoinedListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, JoinedListCellDelegate {
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isEmptyImg: UIImageView!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    var statusArr = [Status]()
    var joinedKeys = [String]()
    var usersArr = [Users]()
    var originController = ""
    var numberLoadMores = 1
    var unjoinedArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        refreshControl.addTarget(self, action: #selector(JoinedListVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if snap.key != "seen" {
                            self.joinedKeys.append(snap.key)
                        }
                    }
                }
                
                self.refresh(sender: self)
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if originController == "activityFeedToJoinedList" {
            tableView.frame.origin.x += 500
            tableView.isHidden = false
            isEmptyImg.frame.origin.x += 500
            
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame.origin.x -= 500
                self.isEmptyImg.frame.origin.x -= 500
            }
        } else if originController == "myProfileToJoinedList" || originController == "pastStatusesToJoinedList" || originController == "editProfileToJoinedList" || originController == "leaveFeedbackToJoinedList" || originController == "friendsListToJoinedList" || originController == "viewProfileToJoinedList" || originController == "joinedFriendsToJoinedList" || originController == "searchToJoinedList" || originController == "mutedConvosToJoinedList" {
            tableView.frame.origin.x -= 500
            tableView.isHidden = false
            isEmptyImg.frame.origin.x -= 500
            
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame.origin.x += 500
                self.isEmptyImg.frame.origin.x += 500
            }
        } else if originController == "" {
            tableView.isHidden = false
            return
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = statusArr[indexPath.row]
        let users = usersArr
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedListCell") as? JoinedListCell {
            
            if let currentUser = Auth.auth().currentUser?.uid {
                let join = status.joinedList.keys.contains { (key) -> Bool in
                    key == currentUser
                }
                if join && !unjoinedArr.contains(status.statusKey) {
                    cell.joinBtn.isHidden = true
                    cell.alreadyJoinedBtn.isHidden = false
                } else{
                    cell.joinBtn.isHidden = false
                    cell.alreadyJoinedBtn.isHidden = true
                }
            }
            
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.configureCell(status: status, users: users)
            return cell
        } else {
            return JoinedListCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinedListToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfileKey = sender as! String
                nextVC.originController = "joinedListToViewProfile"
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                
            }
            
        } else if segue.identifier == "joinedListToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "joinedListToHome"
            }
        } else if segue.identifier == "joinedListToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "joinedListToMyProfile"
            }
        } else if segue.identifier == "joinedListToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "joinedListToSearch"
            }
        }
    }
    
    func didPressJoinBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        let userKey = statusArr[tag].userId
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true"])
            DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count])
            
            joinedKeys.append(statusKey)
            
            for index in 0..<unjoinedArr.count {
                if unjoinedArr[index] == statusKey {
                    unjoinedArr.remove(at: index)
                    break
                }
            }
            
        }
        
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count - 1])
            
            unjoinedArr.append(statusKey)
            
            for index in 0..<joinedKeys.count {
                if joinedKeys[index] == statusKey {
                    joinedKeys.remove(at: index)
                    break
                }
            }
            
        }
    }
    
    func didPressProfilePic(_ tag: Int) {
        let userKey = statusArr[tag].userId
        for index in 0..<usersArr.count {
            if userKey == usersArr[index].usersKey {
                let selectedProfileKey = usersArr[index].usersKey
                performSegue(withIdentifier: "joinedListToViewProfile", sender: selectedProfileKey)
            }
        }
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToHome", sender: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToMyProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  statusArr.count + (joinedKeys.count - statusArr.count) >= 10 * numberLoadMores {
            loadMore()
        }
    }
    
    func loadMore() {
        
        if joinedKeys != [] && joinedKeys.count < (numberLoadMores + 1) * 10 {
            
            for index in numberLoadMores * 10..<joinedKeys.count {
                
                DataService.ds.REF_STATUS.child(joinedKeys.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                        
                    }
                    
                    self.tableView.reloadData()
                })
                
                numberLoadMores += 1
            }
            
        } else if joinedKeys != [] && joinedKeys.count >= numberLoadMores * 10 {
            
            for index in numberLoadMores * 10..<(numberLoadMores + 1) * 10 {
                
                DataService.ds.REF_STATUS.child(joinedKeys.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                })
            }
            numberLoadMores += 1
            
        } else if joinedKeys.count == 0 {
            return
        }
    }
    
    func refresh(sender: Any) {
        
        self.isEmptyImg.isHidden = true
        self.isEmptyImg.alpha = 0.0
        
        self.statusArr = []
        numberLoadMores = 1
        
        if joinedKeys != [] && (joinedKeys.count - unjoinedArr.count) < 10 {
            
            for index in 0..<joinedKeys.count {
                
                DataService.ds.REF_STATUS.child(joinedKeys.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard snapshot.exists() else {
                        if let currentUser = Auth.auth().currentUser?.uid {
                            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(self.joinedKeys.sorted().reversed()[index]).removeValue()
                        }
                        return
                    }
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                })
            }
            
        } else if joinedKeys != [] && (joinedKeys.count - unjoinedArr.count) >= 10 {
            
            for index in 0..<10 {
                
                DataService.ds.REF_STATUS.child(joinedKeys.sorted().reversed()[index]).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard snapshot.exists() else {
                        if let currentUser = Auth.auth().currentUser?.uid {
                            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(self.joinedKeys.sorted().reversed()[index]).removeValue()
                        }
                        return
                    }
                    
                    if let statusDict = snapshot.value as? Dictionary<String, Any> {
                        let key = snapshot.key
                        if statusDict.isEmpty == false {
                            let status = Status(statusKey: key, statusData: statusDict)
                            self.statusArr.append(status)
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                })
            }
            
        } else if joinedKeys.count == 0 {
            
            self.statusArr = []
            
            self.isEmptyImg.isHidden = false
            UIView.animate(withDuration: 0.75) {
                self.isEmptyImg.alpha = 1.0
            }
            
        }
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
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
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.refreshControl.endRefreshing()
        }
        
    }
    
}
