//
//  ConversationVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class ConversationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicImg: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var footerNewFriendIndicator: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //get conversation id
        //load data by message posted date (use append)
        //use if to decide which view to place content in (receiver vs sender)
        //use if last to display and format time
        //load table bottome up, or automatically place scroll position to bottom
        //add placeholder text
        //grow textview input
        //autosizing view using >= lbl width
        //translate table up if pressed or down if scrolling
        
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell") as? ConversationCell {
            //cell.configureCell(conversation: conversation, users: users)
            //cell.selectionStyle = .none
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 120
            
            return cell
        } else {
            return ConversationCell()
        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
    }


}
