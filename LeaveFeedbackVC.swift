//
//  LeaveFeedbackVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/26/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LeaveFeedbackVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var showProfileFooter = false
    var showMsgFooter = false
    let choiceArray = ["Positive", "Negative", "Suggestion", "Inquiry", "Other"]
    let characterLimit = 240
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var selectCategoryBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var characterCountLbl: UILabel!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var characterCountLimitLblBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    @IBOutlet weak var hideTableBtn: UIButton!
    @IBOutlet weak var opaqueBackground: UIButton!
    @IBOutlet weak var feedbackNotSentView: RoundedPopUp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        footerNewFriendIndicator.isHidden = !showProfileFooter
        footerNewMsgIndicator.isHidden = !showMsgFooter
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Please select a category..."
        placeholderLabel.font = UIFont(name: "AvenirNext-UltralightItalic", size: 16)
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        NotificationCenter.default.addObserver(self, selector: #selector(LeaveFeedbackVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        selectCategoryBtn.frame.origin.x += 500
        selectCategoryBtn.isHidden = false
        textView.frame.origin.x += 500
        textView.isHidden = false
        characterCountLbl.frame.origin.x += 500
        characterCountLbl.isHidden = false
        
        UIView.animate(withDuration: 0.25) {
            
            self.selectCategoryBtn.frame.origin.x -= 500
            self.textView.frame.origin.x -= 500
            self.characterCountLbl.frame.origin.x -= 500
            
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            characterCountLimitLblBottomConstraint.constant = keyboardSize.height + 25
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if tableView.isHidden == false {
            tableView.isHidden = true
        }
        characterCountLbl.text = "\(textView.text.count) / \(characterLimit) max characters remaining"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        if updatedText.contains("\n") {
            return false
        }
        return updatedText.count <= characterLimit
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as UITableViewCell
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.textLabel?.text = choiceArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = choiceArray[indexPath.row] as String
        selectCategoryBtn.setTitle(selectedItem, for: .normal)
        
        if selectedItem == "Positive" {
            placeholderLabel.text = "Glad you enjoy the app!"
            textView.becomeFirstResponder()
            homeBtn.isEnabled = false
            errorLbl.isHidden = true
            tableView.isHidden = true
        } else if selectedItem == "Negative" {
            placeholderLabel.text = "What is wrong?"
            textView.becomeFirstResponder()
            homeBtn.isEnabled = false
            errorLbl.isHidden = true
            tableView.isHidden = true
        } else if selectedItem == "Suggestion" {
            placeholderLabel.text = "How can we improve?"
            textView.becomeFirstResponder()
            homeBtn.isEnabled = false
            errorLbl.isHidden = true
            tableView.isHidden = true
        } else if selectedItem == "Inquiry" {
            placeholderLabel.text = "Any questions?"
            textView.becomeFirstResponder()
            homeBtn.isEnabled = false
            errorLbl.isHidden = true
            tableView.isHidden = true
        } else if selectedItem == "Other" {
            placeholderLabel.text = "What can we do for you?"
            textView.becomeFirstResponder()
            homeBtn.isEnabled = false
            errorLbl.isHidden = true
            tableView.isHidden = true
        }
    }
    
    @IBAction func hideTableBtnPressed(_ sender: Any) {
        if tableView.isHidden == false {
            tableView.isHidden = true
        }
        hideTableBtn.isHidden = true
    }
    
    @IBAction func selectCategoryBtnPressed(_ sender: Any) {
        
        if tableView.isHidden == true {
            tableView.isHidden = false
            hideTableBtn.isHidden = false
        } else {
            tableView.isHidden = true
        }
        
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        if selectCategoryBtn.titleLabel?.text == "Select Category" {
            errorLbl.isHidden = false
        } else if textView.text.isEmpty {
            textView.resignFirstResponder()
            performSegue(withIdentifier: "leaveFeedbackToMyProfile", sender: nil)
        }else {
            if let currentUser = Auth.auth().currentUser?.uid {
                let childUpdates = ["content": textView.text,
                                    "user": currentUser,
                                    "postedDate": ServerValue.timestamp()] as [String : Any]
                if let category = selectCategoryBtn.titleLabel?.text {
                    
                    let key = DataService.ds.REF_BASE.child("feedback").child(category.lowercased()).childByAutoId().key
                    DataService.ds.REF_BASE.child("feedback").child(category.lowercased()).child(key).updateChildValues(childUpdates)
                    textView.resignFirstResponder()
                    performSegue(withIdentifier: "leaveFeedbackToMyProfile", sender: nil)
                }
            }
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        if !textView.text.isEmpty {
            
            textView.resignFirstResponder()
            opaqueBackground.isHidden = false
            feedbackNotSentView.frame.origin.y += 1000
            feedbackNotSentView.isHidden = false
            
            UIView.animate(withDuration: 0.25) {
                self.feedbackNotSentView.frame.origin.y -= 1000
            }
            
        } else {
            textView.resignFirstResponder()
            performSegue(withIdentifier: "leaveFeedbackToMyProfile", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaveFeedbackToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "leaveFeedbackToHome"
            }
        } else if segue.identifier == "leaveFeedbackToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "leaveFeedbackToMyProfile"
            }
        } else if segue.identifier == "leaveFeedbackToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "leaveFeedbackToJoinedList"
            }
        } else if segue.identifier == "leaveFeedbackToSearch" {
            if let nextVC = segue.destination as? SearchProfilesVC {
                nextVC.originController = "leaveFeedbackToSearch"
            }
        }
    }
    
    @IBAction func stayBtnPressed(_ sender: Any) {
        
        opaqueBackground.isHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.feedbackNotSentView.frame.origin.y += 1000
        }
        
        let when = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.textView.becomeFirstResponder()
            self.feedbackNotSentView.isHidden = true
            self.feedbackNotSentView.frame.origin.y -= 1000
        }
    }
    
    @IBAction func continueBtnPressed(_ sender: Any) {
        self.textView.resignFirstResponder()
        self.performSegue(withIdentifier: "leaveFeedbackToMyProfile", sender: nil)
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "leaveFeedbackToHome", sender: nil)
    }
    
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "leaveFeedbackToJoinedList", sender: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "leaveFeedbackToSearch", sender: nil)
    }
    
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "leaveFeedbackToMyProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
}
