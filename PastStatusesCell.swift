//
//  PastStatusesCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/13/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        contentLbl.text = textView.text
        textView.resignFirstResponder()
        
        
    }
    
}
