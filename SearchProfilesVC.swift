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
    @IBOutlet weak var topChoiceBtn: UIButton!
    @IBOutlet weak var profilesChoiceBtn: UIButton!
    @IBOutlet weak var citiesChoiceBtn: UIButton!
    @IBOutlet weak var topIndicatorView: UIView!
    @IBOutlet weak var profilesIndicatorView: UIView!
    @IBOutlet weak var citiesIndicatorView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        performSearch(searchBar, searchText: self.searchText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.segmentChoice.selectedSegmentIndex = 0
        
        profilesTableView.delegate = self
        profilesTableView.dataSource = self
        statusesTableView.delegate = self
        statusesTableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        profilesTableView.keyboardDismissMode = .onDrag
        
        //searchBar.backgroundImage = UIImage()
        //searchBar.layer.borderWidth = 1.0
        //searchBar.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        
        //segmentChoice.layer.borderWidth = 1.5
        //segmentChoice.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        if profilesIndicatorView.isHidden == false {
            profileSearchResults.removeAll()
            profilesTableView.reloadData()
        } else if citiesIndicatorView.isHidden == false {
            statusSearchResults.removeAll()
            statusesTableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if profilesIndicatorView.isHidden == false {
            
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
            
        } else if citiesIndicatorView.isHidden == false {
            
            statusSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let cityCheck = status.city as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                //                let cityCheck = user.currentCity as NSString
                //                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return cityRange.location != NSNotFound //|| cityRange.location != NSNotFound
                
            })
            
            //        if(filtered.count == 0){
            //            searchActive = false
            //        } else {
            //            searchActive = true;
            //        }
            
            self.statusesTableView.reloadData()
        }
    }
    
    func performSearch(_ searchBar: UISearchBar, searchText: String) {
        
        if profilesIndicatorView.isHidden == false {
            
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
            
        } else if citiesIndicatorView.isHidden == false {
            
            statusSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let cityCheck = status.city as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                //                let cityCheck = user.currentCity as NSString
                //                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return cityRange.location != NSNotFound //|| cityRange.location != NSNotFound
                
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
        
        if profilesIndicatorView.isHidden == false {
            return profileSearchResults.count
        }
        //print(statusSearchResults.count)
        return statusSearchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let user = searchResults[indexPath.row]
        //let status = statusArr[indexPath.row]
        
        if profilesIndicatorView.isHidden == false {
            
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
            
        } else if citiesIndicatorView.isHidden == false {
            
            let status = statusArr[indexPath.row]
            usersArr.append(currentUserInfo)
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCityCell") as? SearchCityCell {
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.configureCell(status: status, users: usersArr)
                return cell
            }
            
        }
        return SearchCityCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if profilesIndicatorView.isHidden == false {
            let selectedUser = profileSearchResults[indexPath.row]
            performSegue(withIdentifier: "searchToViewProfile", sender: selectedUser)
        }
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
    @IBAction func didPressTopChoiceBtn(_ sender: UIButton) {
        topChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        topIndicatorView.isHidden = false
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = true
    }
    @IBAction func didPressProfilesChoiceBtn(_ sender: UIButton) {
        topChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        topIndicatorView.isHidden = true
        profilesIndicatorView.isHidden = false
        citiesIndicatorView.isHidden = true
        
        profileSearchResults.removeAll()
//        segmentChoice.tintColor = UIColor.white
//        let segAttributes: NSDictionary = [
//            NSForegroundColorAttributeName: UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)//,
//            //NSFontAttributeName: UIFont(name: "Avenir-MediumOblique", size: 20)!
//        ]
//        segmentChoice.setTitleTextAttributes(segAttributes as? [AnyHashable : Any], for: .selected)
        
        if let searchText = searchBar.text {
            performSearch(searchBar, searchText: searchText)
        }
        
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
        
    }
    @IBAction func didPressCitiesChoiceBtn(_ sender: UIButton) {
        topChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        topIndicatorView.isHidden = true
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = false
        
        statusSearchResults.removeAll()
        
        if let searchText = searchBar.text {
            performSearch(searchBar, searchText: searchText)
        }
        
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
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("USERS: \(snap)")
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        //                            if let currentUser = Auth.auth().currentUser?.uid {
                        //                                if currentUser == users.usersKey {
                        //                                    let newFriend = users.friendsList.values.contains { (value) -> Bool in
                        //                                        value as? String == "received"
                        //                                    }
                        //                                    if newFriend && users.friendsList["seen"] as? String == "false" {
                        //                                        //self.footerNewFriendIndicator.isHidden = false
                        //                                    }
                        //                                    let newJoin = users.joinedList.values.contains { (value) -> Bool in
                        //                                        value as? String == "false"
                        //                                    }
                        //                                    if newJoin {
                        //                                        //self.footerNewFriendIndicator.isHidden = false
                        //                                    }
                        //                                    self.currentUserInfo = users
                        //
                        //                                }
                        //                            }
                        
                        self.usersArr.append(users)
                        
                        //                            if let currentUser = Auth.auth().currentUser?.uid {
                        //                                if users.usersKey == currentUser {
                        //                                    self.usersArr.removeLast()
                        //                                }
                        //                            }
                    }
                }
            }
            self.profilesTableView.reloadData()
            
        })
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
            print("hi")
//            profileSearchResults.removeAll()
//            segmentChoice.tintColor = UIColor.white
//            let segAttributes: NSDictionary = [
//                NSForegroundColorAttributeName: UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)//,
//                //NSFontAttributeName: UIFont(name: "Avenir-MediumOblique", size: 20)!
//            ]
//            segmentChoice.setTitleTextAttributes(segAttributes as? [AnyHashable : Any], for: .selected)
//            
//            if let searchText = searchBar.text {
//                performSearch(searchBar, searchText: searchText)
//            }
//            
//            statusesTableView.isHidden = true
//            profilesTableView.isHidden = false
//            
//            DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                self.usersArr = []
//                
//                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                    for snap in snapshot {
//                        //print("USERS: \(snap)")
//                        if let usersDict = snap.value as? Dictionary<String, Any> {
//                            let key = snap.key
//                            let users = Users(usersKey: key, usersData: usersDict)
//                            if let currentUser = Auth.auth().currentUser?.uid {
//                                if currentUser == users.usersKey {
//                                    let newFriend = users.friendsList.values.contains { (value) -> Bool in
//                                        value as? String == "received"
//                                    }
//                                    if newFriend && users.friendsList["seen"] as? String == "false" {
//                                        //self.footerNewFriendIndicator.isHidden = false
//                                    }
//                                    let newJoin = users.joinedList.values.contains { (value) -> Bool in
//                                        value as? String == "false"
//                                    }
//                                    if newJoin {
//                                        //self.footerNewFriendIndicator.isHidden = false
//                                    }
//                                    self.currentUserInfo = users
//                                    
//                                }
//                            }
//                            
//                            self.usersArr.append(users)
//                            
//                            if let currentUser = Auth.auth().currentUser?.uid {
//                                if users.usersKey == currentUser {
//                                    self.usersArr.removeLast()
//                                }
//                            }
//                        }
//                    }
//                }
//                self.profilesTableView.reloadData()
//                
//            })
        case 1:
            print("hi")
            
//            statusSearchResults.removeAll()
//            
//            if let searchText = searchBar.text {
//                performSearch(searchBar, searchText: searchText)
//            }
//            
//            statusesTableView.rowHeight = UITableViewAutomaticDimension
//            statusesTableView.estimatedRowHeight = 90
//            
//            profilesTableView.isHidden = true
//            statusesTableView.isHidden = false
//            
//            DataService.ds.REF_STATUS.queryOrdered(byChild: "joinedNumber").observeSingleEvent(of: .value, with: { (snapshot) in
//                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                    for snap in snapshot {
//                        //print("STATUS: \(snap)")
//                        if let statusDict = snap.value as? Dictionary<String, Any> {
//                            let key = snap.key
//                            let status = Status(statusKey: key, statusData: statusDict)
//                            //                            let friends = self.userFriendsList.keys.contains { (key) -> Bool in
//                            //                                status.userId == key
//                            //                            }
//                            //                            if friends {
//                            //                                if self.userFriendsList[status.userId] as? String == "friends" {
//                            //                                    //print("friends - \(status.userId)")
//                            //                                    self.statusArr.insert(status, at: 0)
//                            //                                    //print(self.statusArr)
//                            //                                }
//                            //                            }
//                            self.statusArr.insert(status, at: 0)
//                        }
//                    }
//                }
//                self.statusesTableView.reloadData()
//            })
//            
//            DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                self.usersArr = []
//                
//                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                    for snap in snapshot {
//                        //print("USERS: \(snap)")
//                        if let usersDict = snap.value as? Dictionary<String, Any> {
//                            let key = snap.key
//                            let users = Users(usersKey: key, usersData: usersDict)
//                            //                            if let currentUser = Auth.auth().currentUser?.uid {
//                            //                                if currentUser == users.usersKey {
//                            //                                    let newFriend = users.friendsList.values.contains { (value) -> Bool in
//                            //                                        value as? String == "received"
//                            //                                    }
//                            //                                    if newFriend && users.friendsList["seen"] as? String == "false" {
//                            //                                        //self.footerNewFriendIndicator.isHidden = false
//                            //                                    }
//                            //                                    let newJoin = users.joinedList.values.contains { (value) -> Bool in
//                            //                                        value as? String == "false"
//                            //                                    }
//                            //                                    if newJoin {
//                            //                                        //self.footerNewFriendIndicator.isHidden = false
//                            //                                    }
//                            //                                    self.currentUserInfo = users
//                            //
//                            //                                }
//                            //                            }
//                            
//                            self.usersArr.append(users)
//                            
//                            //                            if let currentUser = Auth.auth().currentUser?.uid {
//                            //                                if users.usersKey == currentUser {
//                            //                                    self.usersArr.removeLast()
//                            //                                }
//                            //                            }
//                        }
//                    }
//                }
//                self.profilesTableView.reloadData()
//                
//            })
            
            //load status, also ad segment selected to count and cell for row at
            //might need 2 separate views
            //very ambitious but may payoff
            break
        default:
            break
        }
        
        
    }
    
    func refresh(sender: Any) {
        //refresh
    }
}
