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
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var alreadyJoinedBtn: UIButton!
    @IBOutlet weak var newJoinIndicator: UIView!
    
    //var pressedBtnTags = [Int]()
    
    weak var cellDelegate: PastStatusCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(status: Status) {
        
        numberJoinedLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(numberJoinedTapped(_:))))
        
        statusAgeLbl.text = configureTimeAgo(unixTimestamp: status.postedDate)
        contentLbl.text = status.content
        numberJoinedLbl.text = "\(status.joinedList.count - 1) Joined"
        if status.joinedList["seen"] as? String == "false" {
            newJoinIndicator.isHidden = false
        }
        
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
        } else if (daysInterval >= 1 && daysInterval < 15) {
            if daysInterval == 1 {
                return ("\(daysInterval) day ago")
            } else {
                return("\(daysInterval) days ago")
            }
        } else if daysInterval >= 15 {
            
            let shortenedUnix = unixTimestamp / 1000
            let date = Date(timeIntervalSince1970: shortenedUnix)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MM/dd/yyyy" //Specify your format that you want
            var strDate = dateFormatter.string(from: date)
            if strDate.characters.first == "0" {
                strDate.characters.removeFirst()
                return strDate
            }
            return strDate
            
        } else {
            return ("a few seconds ago")
        }
    }
    
    func numberJoinedTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.didPressJoinedList(self.tag)
    }
    
    @IBAction func joinBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressJoinBtn(self.tag)
        joinBtn.isHidden = true
        alreadyJoinedBtn.isHidden = false
        
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
    
    @IBAction func alreadyJoinedBtnPressed(_ sender: UIButton) {
        cellDelegate?.didPressAlreadyJoinedBtn(self.tag)
        joinBtn.isHidden = false
        alreadyJoinedBtn.isHidden = true
        
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
