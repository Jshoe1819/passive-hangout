//
//  JoinedListVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/30/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class JoinedListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, JoinedListCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    var statusArr = [Status]()
    var usersArr = [Users]()
    var currentUser: Users!
    var joinedList = [Status]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        for keys in 0..<statusArr.count {
            let join = currentUser.joinedList.keys.contains { (key) -> Bool in
                key == statusArr[keys].statusKey
            }
            if join {
                joinedList.append(statusArr[keys])
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return joinedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = joinedList[indexPath.row]
        let users = usersArr
        
//        if joinedList.count ==  1 {
//            //create a promt for empty, do same for all other tableviews
//            return JoinedListCell()
//        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedListCell") as? JoinedListCell {
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
                //only use back button on non main buttons
                //have data loaders on main buttons
                //instant loads on main btns
                //hide notification on first press, add seen property?
                //can initialize user with seen: true for friends list and joined list(?)
                //   can manipulate fonts
            }
        }
    }
    
    func didPressJoinBtn(_ tag: Int) {
        let statusKey = joinedList[tag].statusKey
        DataService.ds.REF_USERS.child(currentUser.usersKey).child("joinedList").updateChildValues([statusKey: "true" ])
        DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser.usersKey: "true"])
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        let statusKey = joinedList[tag].statusKey
        DataService.ds.REF_USERS.child(currentUser.usersKey).child("joinedList").child(statusKey).removeValue()
        DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser.usersKey).removeValue()
    }
    
    func didPressProfilePic(_ tag: Int) {
        let userKey = joinedList[tag].userId
        for index in 0..<usersArr.count {
            if userKey == usersArr[index].usersKey {
                let selectedProfile = usersArr[index]
                performSegue(withIdentifier: "joinedListToViewProfile", sender: selectedProfile)
            }
        }
    }
    
    func didPressStatusContentLbl(_ tag: Int) {
        print(tag)
        //        let usersKey = statusArr[tag].userId
        //        for index in 0..<usersArr.count {
        //           if usersArr[index].usersKey == usersKey {
        //                print(usersArr[index].cover["source"])
        //                //send to conversation
        //            }
        //        }
    }

    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToHome", sender: nil)
    }
    @IBAction func joinedBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "joinedListToMyProfile", sender: nil)
    }
    
    
}
