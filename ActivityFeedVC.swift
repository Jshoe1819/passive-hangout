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


class ActivityFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var statusArr = [Status]()
    var usersArr = [Users]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: NewStatusTextView!
    @IBOutlet weak var statusPopupBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusPopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var opaqueStatusBackground: UIButton!
    var placeholderLabel : UILabel!
    @IBOutlet weak var availableSelected: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel.text = EMPTY_STATUS_STRING
        placeholderLabel.lineBreakMode = .byWordWrapping
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        DataService.ds.REF_STATUS.observe(.value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
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
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if Auth.auth().currentUser?.uid == key  {
                            let currentStatus = usersDict["statusId"]
                            print(currentStatus!)
                        }
                        self.usersArr.append(users)
                        
                    }
                }
            }
            self.tableView.reloadData()
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
        let users = usersArr
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            cell.configureCell(status: status, users: users)
            return cell
        } else {
            return FeedCell()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newStatusBtn(_ sender: Any) {
        statusPopupBottomConstraint.constant = 272
        statusPopupTopConstraint.constant = 5
        opaqueStatusBackground.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textViewDidChange(self.textView)
            self.textView.becomeFirstResponder()
            //self.textView.textViewDidBeginEditing(self.textView)
        })
    }
    
    @IBAction func cancelNewStatus(_ sender: Any) {
        statusPopupBottomConstraint.constant = -325
        statusPopupTopConstraint.constant = 680
        opaqueStatusBackground.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.textView.resignFirstResponder()
            self.textView.text = ""
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @IBAction func saveStatusBtnPressed(_ sender: Any) {
        guard let statusContent = textView.text, statusContent != "" else {
            print("JAKE: status content empty")
            return
        }
        
        if let statusContent = textView.text {
            if let user = Auth.auth().currentUser {
                print("JAKE: GOT A USER")
                let userId = user.uid
                let key = DataService.ds.REF_BASE.child("status").childByAutoId().key
                let status = ["available": setAvailable(segmentControl: availableSelected),
                              "content": statusContent,
                              "joinedList": [" ", true],
                              "joinedNumber": 0,
                              "userId": userId] as [String : Any]
                let childUpdates = ["/status/\(key)": status,
                                    "/users/\(userId)/statusId": key] as [String : Any]
                print("JAKE: status - \(status)")
                //DataService.ds.REF_STATUS.child("\(currentStatus)")
                DataService.ds.REF_BASE.updateChildValues(childUpdates)
                //DataService.ds.REF_STATUS
                
            }
        }
    }
    
    func setAvailable(segmentControl: UISegmentedControl) -> Bool {
        if segmentControl.selectedSegmentIndex == 0 {
            return true
        } else {
            return false
        }
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
