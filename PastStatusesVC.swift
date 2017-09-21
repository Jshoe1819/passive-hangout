//
//  PastStatusesVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PastStatusesVC: UIViewController, PastStatusCellDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var statusArr = [Status]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if status.userId == currentUser {
                                self.statusArr.insert(status, at: 0)
                            }
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
        return statusArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = statusArr[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PastStatusesCell") as? PastStatusesCell {
            cell.cellDelegate = self
            cell.tag = indexPath.row
            cell.configureCell(status: status)
            return cell
        } else {
            return PastStatusesCell()
        }
    }
    
    func didPressEditBtn(_ tag: Int) {
        //print("I have pressed a edit button with a tag: \(tag)")
        
    }
    
    func didPressDeleteBtn(_ tag: Int) {
        //print("I have pressed a delete button with a tag: \(tag)")
        
        // create the alert
        let alert = UIAlertController(title: "Delete Status", message: "Are you sure you would like to delete this status?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            if let currentUser = Auth.auth().currentUser?.uid {
                DataService.ds.REF_STATUS.child(self.statusArr[tag].statusKey).removeValue()
                DataService.ds.REF_USERS.child(currentUser).child("statusId").child(self.statusArr[tag].statusKey).removeValue()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func didPressSaveBtn(_ tag: Int, text: String) {
        //print("I have pressed a save button with a tag: \(tag)")
        DataService.ds.REF_STATUS.updateChildValues(["/\(statusArr[tag].statusKey)/content": text])
        
    }
    
    func didPressCancelBtn(_ tag: Int) {
        //print("I have pressed a cancel button with a tag: \(tag)")
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToMyProfile", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToActivityFeed", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "pastStatusesToMyProfile", sender: nil)
    }
    
    
    
}
