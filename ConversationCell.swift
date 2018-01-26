//
//  ConversationCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var senderMsgLbl: UILabel!
    @IBOutlet weak var sentMsgAgeLbl: UILabel!
    @IBOutlet weak var receiverMsgLbl: UILabel!
    @IBOutlet weak var receivedMsgAgeLbl: UILabel!
    
    func configureCell(message: Messages) {
        
        receiverMsgLbl.text = ""
        senderMsgLbl.text = ""
        sentMsgAgeLbl.text = ""
        receivedMsgAgeLbl.text = ""

        receivedMsgAgeLbl.isHidden = true
        receiverMsgLbl.isHidden = true
        senderMsgLbl.isHidden = true
        sentMsgAgeLbl.isHidden = true
        
        
        if let currentUser = Auth.auth().currentUser?.uid {
            if message.senderuid == currentUser {
                senderMsgLbl.isHidden = false
                senderMsgLbl.numberOfLines = 0
                senderMsgLbl.lineBreakMode = .byWordWrapping
                senderMsgLbl.text = message.content
                senderMsgLbl.sizeToFit()
                senderMsgLbl.layoutIfNeeded()

            } else if message.senderuid != currentUser {
                receiverMsgLbl.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
                receiverMsgLbl.isHidden = false
                receiverMsgLbl.numberOfLines = 0
                receiverMsgLbl.lineBreakMode = .byWordWrapping
                receiverMsgLbl.text = message.content
                receiverMsgLbl.sizeToFit()
                receiverMsgLbl.layoutIfNeeded()
            }
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
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MM/dd/yyyy"
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
    
}
