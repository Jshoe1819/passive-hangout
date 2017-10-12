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
    var statusArr = [Status]()
    var currentUserInfo: Users!
    var profileSearchResults = [Users]()
    var statusSearchResults = [Status]()
    var searchText = ""
    
    @IBOutlet weak var profilesTableView: UITableView!
    @IBOutlet weak var statusesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentChoice: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.segmentChoice.selectedSegmentIndex = 0
        
        profilesTableView.delegate = self
        profilesTableView.dataSource = self
        statusesTableView.delegate = self
        statusesTableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor.purple
        profilesTableView.keyboardDismissMode = .onDrag
        
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
                        
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if users.usersKey == currentUser {
                                self.usersArr.removeLast()
                            }
                        }
                    }
                }
            }
            self.profilesTableView.reloadData()
            
        })
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        if segmentChoice.selectedSegmentIndex == 0 {
            profileSearchResults.removeAll()
            profilesTableView.reloadData()
        } else if segmentChoice.selectedSegmentIndex == 1 {
            statusSearchResults.removeAll()
            statusesTableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.showsCancelButton = true
        
        if segmentChoice.selectedSegmentIndex == 0 {
            
            profileSearchResults = usersArr.filter({ (user) -> Bool in
                
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
            
            self.profilesTableView.reloadData()
            
        } else if segmentChoice.selectedSegmentIndex == 1 {
            statusSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let contentCheck = status.content as NSString
                let contentRange = contentCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                //                let cityCheck = user.currentCity as NSString
                //                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return contentRange.location != NSNotFound //|| cityRange.location != NSNotFound
                
            })
            
            //        if(filtered.count == 0){
            //            searchActive = false
            //        } else {
            //            searchActive = true;
            //        }
            
            self.statusesTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentChoice.selectedSegmentIndex == 0 {
            return profileSearchResults.count
        }
        
        return statusSearchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let user = searchResults[indexPath.row]
        //let status = statusArr[indexPath.row]
        
        if segmentChoice.selectedSegmentIndex == 0 {
            
            let user = profileSearchResults[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchProfilesCell") as? SearchProfilesCell {
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.addFriendBtn.isHidden = true
                cell.requestSentBtn.isHidden = true
                cell.configureCell(user: user, currentUser: currentUserInfo)
                return cell
            }
        } else if segmentChoice.selectedSegmentIndex == 1 {
            
            let status = statusArr[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCityCell") as? SearchCityCell {
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.configureCell(status: status, users: usersArr)
                return cell
            }
            
        }
        return SearchProfilesCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = profileSearchResults[indexPath.row]
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
        let friendKey = profileSearchResults[tag].usersKey
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").updateChildValues([friendKey: "sent"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUserInfo.usersKey: "received"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues(["seen": "false"])
    }
    
    func didPressRequestSentBtn(_ tag: Int) {
        print(tag)
        let friendKey = profileSearchResults[tag].usersKey
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").child(friendKey).removeValue()
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUserInfo.usersKey).removeValue()
    }
    
    func didPressProfilePic(_ tag: Int) {
        let selectedUser = profileSearchResults[tag]
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
    @IBAction func segmentChoiceBtnPressed(_ sender: Any) {
        
        switch segmentChoice.selectedSegmentIndex {
        case 0:
            
            profileSearchResults.removeAll()
            
            statusesTableView.isHidden = true
            profilesTableView.isHidden = false
            
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
                            
                            if let currentUser = Auth.auth().currentUser?.uid {
                                if users.usersKey == currentUser {
                                    self.usersArr.removeLast()
                                }
                            }
                        }
                    }
                }
                self.profilesTableView.reloadData()
                
            })
        case 1:
            
            statusSearchResults.removeAll()
            
            statusesTableView.rowHeight = UITableViewAutomaticDimension
            statusesTableView.estimatedRowHeight = 90
            
            profilesTableView.isHidden = true
            statusesTableView.isHidden = false
            
            DataService.ds.REF_STATUS.queryOrdered(byChild: "joinedNumber").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        //print("STATUS: \(snap)")
                        if let statusDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let status = Status(statusKey: key, statusData: statusDict)
                            //                            let friends = self.userFriendsList.keys.contains { (key) -> Bool in
                            //                                status.userId == key
                            //                            }
                            //                            if friends {
                            //                                if self.userFriendsList[status.userId] as? String == "friends" {
                            //                                    //print("friends - \(status.userId)")
                            //                                    self.statusArr.insert(status, at: 0)
                            //                                    //print(self.statusArr)
                            //                                }
                            //                            }
                            self.statusArr.insert(status, at: 0)
                        }
                    }
                }
                self.statusesTableView.reloadData()
            })
            
            //load status, also ad segment selected to count and cell for row at
            //might need 2 separate views
            //very ambitious but may payoff
            break
        default:
            break
        }
        
        
    }
}
