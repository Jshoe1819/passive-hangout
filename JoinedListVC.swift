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
    var usersArr = [Users]()
    //var currentUser: Users!
    //var joinedList = [Status]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.purple
        refreshControl.addTarget(self, action: #selector(JoinedListVC.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            let join = status.joinedList.keys.contains { (key) -> Bool in
                                key == currentUser
                            }
                            if join {
                                self.statusArr.insert(status, at: 0)
                            }
                            
                        }
                    }
                }
            }
            if self.statusArr.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
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
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tableView.frame.origin.x += 500
        
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x -= 500
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
        
        //        if joinedList.count ==  1 {
        //            //create a promt for empty, do same for all other tableviews
        //            return JoinedListCell()
        //        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedListCell") as? JoinedListCell {
            cell.alreadyJoinedBtn.isHidden = false
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.configureCell(status: status, users: users)
            return cell
        } else {
            return JoinedListCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinedListToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                nextVC.originController = "joinedListToViewProfile"
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                //only use back button on non main buttons
                //have data loaders on main buttons
                //instant loads on main btns
                //hide notification on first press, add seen property?
                //can initialize user with seen: true for friends list and joined list(?)
                //   can manipulate fonts
            }
        } else if segue.identifier == "joinedListToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "joinedListToHome"
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
            //tableView.reloadData()
        }
        
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = statusArr[tag].statusKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
            DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count - 1])
            //tableView.reloadData()
        }
    }
    
    func didPressProfilePic(_ tag: Int) {
        let userKey = statusArr[tag].userId
        for index in 0..<usersArr.count {
            if userKey == usersArr[index].usersKey {
                let selectedProfile = usersArr[index]
                performSegue(withIdentifier: "joinedListToViewProfile", sender: selectedProfile)
            }
        }
    }
    
//    func didPressStatusContentLbl(_ tag: Int) {
//        print(tag)
//        //        let usersKey = statusArr[tag].userId
//        //        for index in 0..<usersArr.count {
//        //           if usersArr[index].usersKey == usersKey {
//        //                print(usersArr[index].cover["source"])
//        //                //send to conversation
//        //            }
//        //        }
//    }
    
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToHome", sender: nil)
    }
    @IBAction func joinedBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToSearch", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToMyProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
    func refresh(sender: Any) {
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            let join = status.joinedList.keys.contains { (key) -> Bool in
                                key == currentUser
                            }
                            if join {
                                self.statusArr.insert(status, at: 0)
                            }
                            
                        }
                    }
                }
            }
            if self.statusArr.count == 0 {
                self.isEmptyImg.isHidden = false
            } else {
                self.isEmptyImg.isHidden = true
            }
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
                                let answer = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if answer && users.friendsList["seen"] as? String == "false" {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.refreshControl.endRefreshing()
        }
        
        
    }
    
    
}
