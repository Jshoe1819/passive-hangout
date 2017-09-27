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

class FriendsListVC: UIViewController, FriendsListCellDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var usersArr = [Users]()
    var currentFriendsList = Dictionary<String, Any>()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                            if let value = snap.value {
                                self.currentFriendsList.updateValue(value, forKey: snap.key)
                            }
                    }
                }
            })
        }
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if self.currentFriendsList.keys.contains(users.usersKey) {
                            self.usersArr.append(users)
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let users = usersArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "friendsListCell", for: indexPath) as? FriendsListCell {
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.configureCell(friendsList: currentFriendsList, users: users)
            return cell
        } else {
            return FriendsListCell()
        }
        
    }
    
    func didPressMenuBtn(_ tag: Int) {
        print(tag)
    }
    func didPressAcceptBtn(_ tag: Int) {
        let friendKey = usersArr[tag].usersKey
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child(currentUser).child("friendsList").updateChildValues([friendKey: "friends"])
            DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUser: "friends"])
        }
        tableView.reloadData()
        
    }
    func didPressIgnoreBtn(_ tag: Int) {
        print(tag)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
    }
    
}
