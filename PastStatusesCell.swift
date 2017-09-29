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

class PastStatusesCell: UITableViewCell {
    
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var numberJoinedLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    //var pressedBtnTags = [Int]()
    
    weak var cellDelegate: PastStatusCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    
    @IBAction func joinBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressJoinBtn(self.tag)
    }
    
    
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressMenuBtn(self.tag, textView: textView, label: contentLbl, button: menuBtn)
        
        //pressedBtnTags.append(tag)
        
        
        //        contentLbl.isHidden = true
        //        textView.text = contentLbl.text
        //        textView.isHidden = false
        //        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
        //        textView.becomeFirstResponder()
        
        
    }
    
    //    @IBAction func editStatusBtnPressed(_ sender: UIButton) {
    //        cellDelegate?.didPressEditBtn(self.tag)
    //
    //        contentLbl.isHidden = true
    //        saveBtn.isHidden = false
    //        cancelBtn.isHidden = false
    //        editBtn.isHidden = true
    //        deleteBtn.isHidden = true
    //        textView.isHidden = false
    //        textView.text = contentLbl.text
    //        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
    //        textView.becomeFirstResponder()
    //    }
    //
    //    @IBAction func deleteStatusBtnPressed(_ sender: UIButton) {
    //        cellDelegate?.didPressDeleteBtn(self.tag)
    //    }
    //
    //    @IBAction func cancelBtnPressed(_ sender: UIButton) {
    //        cellDelegate?.didPressCancelBtn(self.tag)
    //
    //        contentLbl.isHidden = false
    //        saveBtn.isHidden = true
    //        cancelBtn.isHidden = true
    ////        editBtn.isHidden = false
    ////        deleteBtn.isHidden = false
    //        menuBtn.isHidden = false
    //        textView.isHidden = true
    //        textView.resignFirstResponder()
    //        saveBtn.isHidden = false
    //        cancelBtn.isHidden = false
    //    }
    //
    //    @IBAction func saveBtnPressed(_ sender: UIButton) {
    //        cellDelegate?.didPressSaveBtn(self.tag, text: textView.text)
    //
    //        contentLbl.isHidden = false
    //        saveBtn.isHidden = true
    //        cancelBtn.isHidden = true
    //        editBtn.isHidden = false
    //        deleteBtn.isHidden = false
    //        //contentLbl.text = textView.text
    //        textView.isHidden = true
    //        textView.resignFirstResponder()
    //    }
    
}
