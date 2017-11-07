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
    
    //@IBOutlet weak var senderBubble: UIView!
    @IBOutlet weak var senderMsgLbl: UILabel!
    @IBOutlet weak var sentMsgAgeLbl: UILabel!
    //@IBOutlet weak var receiverBubble: ReceiverMessageColor!
    @IBOutlet weak var receiverMsgLbl: UILabel!
    @IBOutlet weak var receivedMsgAgeLbl: UILabel!
    //@IBOutlet weak var senderBubbleHeightConstraint: NSLayoutConstraint!
    
    func configureCell(message: Messages) {
        
        
        
        //receiverBubble.isHidden = true
        //receiverBubble.frame.size.height = 0
        //receiverBubble.sizeToFit()
        receivedMsgAgeLbl.isHidden = true
        //receivedMsgAgeLbl.sizeToFit()
        receiverMsgLbl.isHidden = true
        senderMsgLbl.isHidden = true
        //senderBubble.isHidden = true
        //senderBubble.sizeToFit()
        sentMsgAgeLbl.isHidden = true
        //sentMsgAgeLbl.sizeToFit()
        
        
        
        
        //        profilePicImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        //        statusLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentTapped(_:))))
        
        if let currentUser = Auth.auth().currentUser?.uid {
            if message.senderuid == currentUser {
                //senderBubble.isHidden = false
                senderMsgLbl.isHidden = false
                senderMsgLbl.text = message.content
//                print(senderMsgLbl.text!)
//                print(senderMsgLbl.frame.size.height)
//                print("Sent: \(senderMsgLbl.intrinsicContentSize.height)")
                //senderMsgLbl.sizeToFit()
                //layoutIfNeeded()
            } else if message.senderuid != currentUser {
                //receiverBubble.isHidden = false
                receiverMsgLbl.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
                receiverMsgLbl.isHidden = false
                receiverMsgLbl.text = message.content
                //receiverMsgLbl.sizeToFit()
                //receiverBubble.frame.size.height = receiverMsgLbl.frame.height + 10
//                print(receiverMsgLbl.text!)
//                print(receiverMsgLbl.text!)
//                print(receiverMsgLbl.frame.size.height)
//              print("Recvd: \(receiverMsgLbl.intrinsicContentSize.height)")
                //receiverMsgLbl.frame.size = receiverMsgLbl.intrinsicContentSize
                receiverMsgLbl.sizeToFit()
//                print(receiverMsgLbl.frame.height)
                //print(receiverBubble.frame.height)
                //receivedMsgAgeLbl.sizeToFit()
                //layoutIfNeeded()
            }
        }
    }
    
    
    
//    override func layoutIfNeeded() {
//        
//        
//        
//        //print("hi")
//        //receiverBubble.isHidden = true
//        receiverBubble.sizeToFit()
//        //receivedMsgAgeLbl.isHidden = true
//        receivedMsgAgeLbl.sizeToFit()
//        
//        //senderBubble.isHidden = true
//        senderBubble.sizeToFit()
//        //sentMsgAgeLbl.isHidden = true
//        sentMsgAgeLbl.sizeToFit()
//        
//        receiverBubble.frame.size.height = receivedMsgAgeLbl.frame.height
//
//    }

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
