//
//  PastStatusesCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PastStatusesCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var numberJoinedLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    weak var cellDelegate: PastStatusCellDelegate?
    var statusArr = [Status]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        
    }
    
    func configureCell(status: Status) {
        statusAgeLbl.text = configureTimeAgo(unixTimestamp: status.postedDate)
        contentLbl.text = status.content
        numberJoinedLbl.text = "\(status.joinedNumber) Joined"
    }
    
    func configureTimeAgo(unixTimestamp: Double) -> String {
        let date = Date().timeIntervalSince1970
        let secondsInterval = Int((date - unixTimestamp/1000).rounded().nextDown)
        let minutesInterval = secondsInterval / 60
        let hoursInterval = minutesInterval / 60
        let daysInterval = hoursInterval / 24
        
        if (secondsInterval >= 15 && secondsInterval < 60) {
            return("\(secondsInterval) seconds ago")
        } else if (minutesInterval >= 1 && minutesInterval < 60) {
            if minutesInterval == 1 {
                return ("\(minutesInterval) minute ago")
            } else {
                return("\(minutesInterval) minutes ago")
            }
        } else if (hoursInterval >= 1 && hoursInterval < 24) {
            if hoursInterval == 1 {
                return ("\(hoursInterval) hour ago")
            } else {
                return("\(hoursInterval) hours ago")
            }
        } else if (daysInterval >= 1) {
            if daysInterval == 1 {
                return ("\(daysInterval) day ago")
            } else {
                return("\(daysInterval) days ago")
            }
        } else {
            return ("a few seconds ago")
        }
    }
    
    @IBAction func editStatusBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(self.tag)
        contentLbl.isHidden = true
        textView.isHidden = false
        saveBtn.isHidden = false
        cancelBtn.isHidden = false
        editBtn.isHidden = true
        deleteBtn.isHidden = true
        textView.text = contentLbl.text
        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
        textView.becomeFirstResponder()
    }
    
    @IBAction func deleteStatusBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(self.tag)
        
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
                                //                                print("JAKE: entering1")
                                //                                self.statusArr.insert(status, at: 0)
                                if status.content == self.contentLbl.text {
                                    DataService.ds.REF_STATUS.child(status.statusKey).removeValue()
                                    DataService.ds.REF_USERS.child(currentUser).child("statusId").child(status.statusKey).removeValue()
                                }
                            }
                        }
                    }
                    
                }
            }
        })
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(self.tag)
        contentLbl.isHidden = false
        textView.isHidden = true
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
        editBtn.isHidden = false
        deleteBtn.isHidden = false
        textView.resignFirstResponder()
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(self.tag)
        contentLbl.isHidden = false
        textView.isHidden = true
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
        editBtn.isHidden = false
        deleteBtn.isHidden = false
        //contentLbl.text = textView.text
        textView.resignFirstResponder()
        
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
                                //                                print("JAKE: entering1")
                                //                                self.statusArr.insert(status, at: 0)
                                if status.content == self.contentLbl.text {
                                    //print("JAKE: entering2")
                                    if let update = self.textView.text {
                                        //print("JAKE: \(update)")
                                        DataService.ds.REF_STATUS.updateChildValues(["/\(status.statusKey)/content": update])
                                        self.contentLbl.text = self.textView.text
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        })
    }
}
