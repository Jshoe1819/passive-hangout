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
    var tappedBtnTags = [Int]()
    var deleted = [Int]()
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
        performSegue(withIdentifier: "friendsListToViewProfile", sender: nil)
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        if tableView.cellForRow(at: indexPath)?.isHidden == true {
    //            return 0
    //        } else {
    //            return 12
    //        }
    //    }
    
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
            self.tappedBtnTags.removeAll()
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "View Profile", style: UIAlertActionStyle.default, handler: { action in
            
            //perform segue
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
        performSegue(withIdentifier: "friendsListToMyProfie", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToHome", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "friendsListToMyProfie", sender: nil)
    }
    
}
