//
//  MessagesVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var usersArr = [Users]()
    var conversationArr = [Conversation]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var footerNewFriendIndicator: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        DataService.ds.REF_CONVERSATION.queryOrdered(byChild: "/details/lastMsgDate").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.conversationArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("Conversation: \(snap)")
                    if let conversationDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let conversation = Conversation(conversationKey: key, conversationData: conversationDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            let userConversation = conversation.users.keys.contains(currentUser)
                            if userConversation {
                                self.conversationArr.insert(conversation, at: 0)
                            }
                        }
                    }
                }
            }
            //change to explore.reload
//            for index in 0..<self.conversationArr.count {
//                if let lastMsgDate = self.conversationArr[index].details["lastMsgDate"] {
//            print(lastMsgDate)
//                }
//            }
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if currentUser == users.usersKey {
                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if newFriend && users.friendsList["seen"] as? String == "false" {
                                    //self.footerNewFriendIndicator.isHidden = false
                                }
                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
                                    value as? String == "false"
                                }
                                if newJoin {
                                    //self.footerNewFriendIndicator.isHidden = false
                                }
                            }
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
        return conversationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conversation = conversationArr[indexPath.row]
        let users = usersArr
        
         if let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell") as? MessagesCell {
            cell.configureCell(conversation: conversation, users: users)
            cell.selectionStyle = .none
            return cell
         } else {
            return MessagesCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedConversation = conversationArr[indexPath.row].conversationKey
        performSegue(withIdentifier: "messagesToConversation", sender: selectedConversation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messagesToConversation" {
            if let nextVC = segue.destination as? ConversationVC {
                nextVC.conversationUid = sender as! String
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "messagesToFeed", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "messagesToFeed", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "messagesToJoinedList", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "messagesToSearch", sender: nil)
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "messagesToMyProfile", sender: nil)
    }
}
