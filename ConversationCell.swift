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
    
    @IBOutlet weak var senderBubble: UIView!
    @IBOutlet weak var senderMsgLbl: UILabel!
    @IBOutlet weak var sentMsgAgeLbl: UILabel!
    @IBOutlet weak var receiverBubble: ReceiverMessageColor!
    @IBOutlet weak var receiverMsgLbl: UILabel!
    @IBOutlet weak var receivedMsgAgeLbl: UILabel!
    
    func configureCell(message: Messages) {
        
        receiverBubble.isHidden = true
        receivedMsgAgeLbl.isHidden = true
        senderBubble.isHidden = true
        sentMsgAgeLbl.isHidden = true
        
        //        profilePicImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        //        statusLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentTapped(_:))))
        
        if let currentUser = Auth.auth().currentUser?.uid {
            if message.senderuid == currentUser {
                senderBubble.isHidden = false
                senderMsgLbl.text = message.content
                senderMsgLbl.sizeToFit()
                //layoutIfNeeded()
            } else if message.senderuid != currentUser {
                receiverBubble.isHidden = false
                receiverMsgLbl.text = message.content
                receivedMsgAgeLbl.sizeToFit()
                //layoutIfNeeded()
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
    
}
