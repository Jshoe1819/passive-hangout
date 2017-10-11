//
//  SearchProfilesVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/9/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SearchProfilesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchProfilesDelegate {
    
    var usersArr = [Users]()
    var currentUserInfo: Users!
    var searchResults = [Users]()
    var searchText = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor.purple
        tableView.keyboardDismissMode = .onDrag
        
        searchBar.text = searchText
        
        //use search text change to search query?
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
                                self.currentUserInfo = users
                            }
                        }
                        self.usersArr.append(users)
                        
                        if users.usersKey == self.currentUserInfo.usersKey {
                            self.usersArr.removeLast()
                        }
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchResults.removeAll()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.showsCancelButton = true
        
        searchResults = usersArr.filter({ (user) -> Bool in
            
            if searchText == "" {
                return false
            }
            
            let nameCheck = user.name as NSString
            let nameRange = nameCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let cityCheck = user.currentCity as NSString
            let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return nameRange.location != NSNotFound || cityRange.location != NSNotFound
            
        })
        
        //        if(filtered.count == 0){
        //            searchActive = false
        //        } else {
        //            searchActive = true;
        //        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = searchResults[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchProfilesCell") as? SearchProfilesCell {
            cell.cellDelegate = self
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.addFriendBtn.isHidden = true
            cell.requestSentBtn.isHidden = true
            cell.configureCell(user: user, currentUser: currentUserInfo)
            return cell
        }
        return SearchProfilesCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = searchResults[indexPath.row]
        performSegue(withIdentifier: "searchToViewProfile", sender: selectedUser)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfile = sender as? Users
                nextVC.originController = "searchToViewProfile"
                if let text = searchBar.text {
                    nextVC.searchText = text
                }
            }
        }
    }
    
    func didPressAddFriendBtn(_ tag: Int) {
        print(tag)
        let friendKey = searchResults[tag].usersKey
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").updateChildValues([friendKey: "sent"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUserInfo.usersKey: "received"])
    }
    
    func didPressRequestSentBtn(_ tag: Int) {
        print(tag)
        let friendKey = searchResults[tag].usersKey
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").child(friendKey).removeValue()
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUserInfo.usersKey).removeValue()
    }
    
    func didPressProfilePic(_ tag: Int) {
        let selectedUser = searchResults[tag]
        performSegue(withIdentifier: "searchToViewProfile", sender: selectedUser)
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "searchToHome", sender: nil)
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "searchToJoinedList", sender: nil)
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "searchToMyProfile", sender: nil)
    }
}
