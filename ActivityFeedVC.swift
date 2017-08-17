//
//  ActivityFeedVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/12/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import FirebaseDatabase
import Firebase


class ActivityFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var statusArr = [Status]()
    var usersArr = [Users]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_STATUS.observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("SNAP: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.append(status)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("SNAP: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        self.usersArr.append(users)
                    }
                }
            }
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = statusArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.configureCell(status: status)
            return cell
        } else {
            return FeedCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeBTnPressed(_ sender: Any) {
    }
    
    @IBAction func sortBtnPressed(_ sender: Any) {
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "feedToLogin", sender: nil)
        
    }
    
}
