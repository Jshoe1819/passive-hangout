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

class SearchProfilesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ExploreHangoutsDelegate, SearchHangoutsDelegate, SearchProfilesDelegate, SearchCitiesDelegate {
    
    var usersArr = [Users]()
    var statusArr = [Status]()
    var currentUserInfo: Users!
    var searchActive = false
    var hangoutsSearchResults = [Status]()
    var profileSearchResults = [Users]()
    var statusSearchResults = [Status]()
    var searchText = ""
    
    @IBOutlet weak var exploreTableView: UITableView!
    @IBOutlet weak var hangoutsTableView: UITableView!
    @IBOutlet weak var profilesTableView: UITableView!
    @IBOutlet weak var statusesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentChoice: UISegmentedControl!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var searchOptionsStackView: UIStackView!
    @IBOutlet weak var topChoiceBtn: UIButton!
    @IBOutlet weak var profilesChoiceBtn: UIButton!
    @IBOutlet weak var citiesChoiceBtn: UIButton!
    @IBOutlet weak var topIndicatorView: UIView!
    @IBOutlet weak var profilesIndicatorView: UIView!
    @IBOutlet weak var citiesIndicatorView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        //code to refresh
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.segmentChoice.selectedSegmentIndex = 0
        
        exploreTableView.delegate = self
        exploreTableView.dataSource = self
        hangoutsTableView.delegate = self
        hangoutsTableView.dataSource = self
        profilesTableView.delegate = self
        profilesTableView.dataSource = self
        statusesTableView.delegate = self
        statusesTableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        
        hangoutsTableView.keyboardDismissMode = .onDrag
        profilesTableView.keyboardDismissMode = .onDrag
        statusesTableView.keyboardDismissMode = .onDrag
        
        //searchBar.backgroundImage = UIImage()
        //searchBar.layer.borderWidth = 1.0
        //searchBar.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        
        //segmentChoice.layer.borderWidth = 1.5
        //segmentChoice.layer.borderColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1).cgColor
        
        searchBar.text = searchText
        
        //use search text change to search query?
        //        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //            self.usersArr = []
        //
        //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                for snap in snapshot {
        //                    //print("USERS: \(snap)")
        //                    if let usersDict = snap.value as? Dictionary<String, Any> {
        //                        let key = snap.key
        //                        let users = Users(usersKey: key, usersData: usersDict)
        //                        if let currentUser = Auth.auth().currentUser?.uid {
        //                            if currentUser == users.usersKey {
        //                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
        //                                    value as? String == "received"
        //                                }
        //                                if newFriend && users.friendsList["seen"] as? String == "false" {
        //                                    //self.footerNewFriendIndicator.isHidden = false
        //                                }
        //                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
        //                                    value as? String == "false"
        //                                }
        //                                if newJoin {
        //                                    //self.footerNewFriendIndicator.isHidden = false
        //                                }
        //                                self.currentUserInfo = users
        //
        //                            }
        //                        }
        //
        //                        self.usersArr.append(users)
        //
        //                        if let currentUser = Auth.auth().currentUser?.uid {
        //                            if users.usersKey == currentUser {
        //                                self.usersArr.removeLast()
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            self.profilesTableView.reloadData()
        //
        //        })
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "joinedNumber").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //print("STATUS: \(snap)")
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        self.statusArr.insert(status, at: 0)
                    }
                }
            }
            //change to explore.reload
            self.exploreTableView.reloadData()
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
                                self.currentUserInfo = users
                                
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            //change to explire.reload
            self.exploreTableView.reloadData()
        })
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //hide explore
        searchActive = true
        exploreTableView.isHidden = true
        
        searchOptionsStackView.isHidden = false
        bottomSeparatorView.isHidden = false
        if topChoiceBtn.isEnabled == false {
            hangoutsTableView.isHidden = false
            topIndicatorView.isHidden = false
        } else if profilesChoiceBtn.isEnabled == false {
            profilesTableView.isHidden = false
            profilesIndicatorView.isHidden = false
        } else if citiesChoiceBtn.isEnabled == false {
            statusesTableView.isHidden = false
            citiesIndicatorView.isHidden = false
        }
        //        topIndicatorView.isHidden = false
        //        profilesIndicatorView.isHidden = true
        //        citiesIndicatorView.isHidden = true
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //hide all tables, show explore
        searchActive = false
        
        exploreTableView.isHidden = false
        hangoutsTableView.isHidden = true
        profilesTableView.isHidden = true
        statusesTableView.isHidden = true
        
        searchOptionsStackView.isHidden = true
        bottomSeparatorView.isHidden = true
        topIndicatorView.isHidden = true
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = true
        
        hangoutsSearchResults.removeAll()
        profileSearchResults.removeAll()
        statusSearchResults.removeAll()
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        hangoutsTableView.reloadData()
        profilesTableView.reloadData()
        statusesTableView.reloadData()
        
        if topIndicatorView.isHidden == false {
            hangoutsSearchResults.removeAll()
            hangoutsTableView.reloadData()
        } else if profilesIndicatorView.isHidden == false {
            profileSearchResults.removeAll()
            profilesTableView.reloadData()
        } else if citiesIndicatorView.isHidden == false {
            statusSearchResults.removeAll()
            statusesTableView.reloadData()
        }
        
    }
    
    //only show stack if search pressed
    //otherwise show top hangouts all time? dont show number, some kind of explore criteria?
    
    //hangouts - search by city, user, content? (if content use joined number?)
    //profiles - search by user and city, add mutual friends
    //cities - show available list , when clicked show hangouts in that area sorted by number joined
    //if empty use suggestions?
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if topIndicatorView.isHidden == false {
            //change top to hangout
            //            let rand = arc4random_uniform(25)
            //            print(rand)
            
            hangoutsSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let contentCheck = status.content as NSString
                let contentRange = contentCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                
                return contentRange.location != NSNotFound
                
            })
            
            self.hangoutsTableView.reloadData()
            
        } else if profilesIndicatorView.isHidden == false {
            
            profileSearchResults = usersArr.filter({ (user) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let nameCheck = user.name as NSString
                let nameRange = nameCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                let cityCheck = user.currentCity as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                
                //                let mutualFriend = user.friendsList.keys.contains { (key) -> Bool in
                //                    for index in 0..<currentUserInfo.friendsList.count {
                //                        if Array(currentUserInfo.friendsList)[index].key == key {
                //                            return true
                //                        }
                //                    }
                //                    return false
                //                }
                //                if mutualFriend {
                //                    print("hey")
                //                }
                
                return nameRange.location != NSNotFound || cityRange.location != NSNotFound
                
                //                let newFriend = users.friendsList.values.contains { (value) -> Bool in
                //                    value as? String == "received"
                //                }
                
                
                
                
            })
            
            self.profilesTableView.reloadData()
            
        } else if citiesIndicatorView.isHidden == false {
            
            statusSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let cityCheck = status.city as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                
                return cityRange.location != NSNotFound
                
            })
            
            self.statusesTableView.reloadData()
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == false {
            return statusArr.count
        } else if topIndicatorView.isHidden == false {
            return hangoutsSearchResults.count
        } else if profilesIndicatorView.isHidden == false {
            return profileSearchResults.count
        }
        //print(statusSearchResults.count)
        return statusSearchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let user = searchResults[indexPath.row]
        //let status = statusArr[indexPath.row]
        if searchActive == false {
            
            let status = statusArr[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "exploreHangouts") as? ExploreHangoutCell {
                
                if let currentUser = Auth.auth().currentUser?.uid {
                    
                    if status.userId == currentUser {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = true
                    } else {
                        
                        let join = status.joinedList.keys.contains { (key) -> Bool in
                            key == currentUser
                        }
                        if join {
                            cell.joinBtn.isHidden = true
                            cell.alreadyJoinedBtn.isHidden = false
                        } else{
                            cell.joinBtn.isHidden = false
                            cell.alreadyJoinedBtn.isHidden = true
                        }
                    }
                }
                
                exploreTableView.rowHeight = UITableViewAutomaticDimension
                exploreTableView.estimatedRowHeight = 120
                
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.configureCell(status: status, users: usersArr)
                
                return cell
            }
            
        } else if topIndicatorView.isHidden == false {
            
            let status = hangoutsSearchResults[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchByHangout") as? SearchHangoutCell {
                
                if let currentUser = Auth.auth().currentUser?.uid {
                    
                    if status.userId == currentUser {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = true
                    } else {
                        
                        let join = status.joinedList.keys.contains { (key) -> Bool in
                            key == currentUser
                        }
                        if join {
                            cell.joinBtn.isHidden = true
                            cell.alreadyJoinedBtn.isHidden = false
                        } else{
                            cell.joinBtn.isHidden = false
                            cell.alreadyJoinedBtn.isHidden = true
                        }
                    }
                }
                
                hangoutsTableView.rowHeight = UITableViewAutomaticDimension
                hangoutsTableView.estimatedRowHeight = 120
                
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.configureCell(status: status, users: usersArr)
                return cell
            }
            
        }
        if profilesIndicatorView.isHidden == false {
            //if results is empty disable scrolling
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
            
            let status = statusSearchResults[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCityCell") as? SearchCityCell {
                
                if let currentUser = Auth.auth().currentUser?.uid {
                    
                    if status.userId == currentUser {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = true
                    } else {
                        
                        let join = status.joinedList.keys.contains { (key) -> Bool in
                            key == currentUser
                        }
                        if join {
                            cell.joinBtn.isHidden = true
                            cell.alreadyJoinedBtn.isHidden = false
                        } else{
                            cell.joinBtn.isHidden = false
                            cell.alreadyJoinedBtn.isHidden = true
                        }
                    }
                }
                
                statusesTableView.rowHeight = UITableViewAutomaticDimension
                statusesTableView.estimatedRowHeight = 120
                
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
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                let userKey = statusArr[indexPath.row].userId
                if userKey == currentUser {
                    return
                }
                
                for index in 0..<usersArr.count {
                    if userKey == usersArr[index].usersKey {
                        let selectedProfile = usersArr[index]
                        performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfile)
                    }
                }
                
            } else if topIndicatorView.isHidden == false {
                let userKey = hangoutsSearchResults[indexPath.row].userId
                if userKey == currentUser {
                    return
                }
                
                for index in 0..<usersArr.count {
                    if userKey == usersArr[index].usersKey {
                        let selectedProfile = usersArr[index]
                        performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfile)
                    }
                }
                
            } else if profilesIndicatorView.isHidden == false {
                let selectedProfile = profileSearchResults[indexPath.row]
                performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfile)
                
            } else if citiesIndicatorView.isHidden == false {
                let userKey = statusSearchResults[indexPath.row].userId
                if userKey == currentUser {
                    return
                }
                
                for index in 0..<usersArr.count {
                    if userKey == usersArr[index].usersKey {
                        let selectedProfile = usersArr[index]
                        performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfile)
                    }
                }
            }
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
    //    func didPressJoinBtn(_ tag: Int) {
    //        let statusKey = statusArr[tag].statusKey
    //        let userKey = statusArr[tag].userId
    //        if let currentUser = Auth.auth().currentUser?.uid {
    //            DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
    //            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
    //            DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
    //            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
    //        }
    //
    //    }
    //
    //    func didPressAlreadyJoinedBtn(_ tag: Int) {
    //        let statusKey = statusArr[tag].statusKey
    //        if let currentUser = Auth.auth().currentUser?.uid {
    //            DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
    //            DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
    //        }
    //    }
    
    func didPressJoinBtn(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                
                let statusKey = statusArr[tag].statusKey
                let userKey = statusArr[tag].userId
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
                DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
                
            } else if topIndicatorView.isHidden == false {
                
                let statusKey = hangoutsSearchResults[tag].statusKey
                let userKey = hangoutsSearchResults[tag].userId
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
                DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
                
            } else if citiesIndicatorView.isHidden == false {
                
                let statusKey = statusSearchResults[tag].statusKey
                let userKey = statusSearchResults[tag].userId
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
                DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
                
            }
        }
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                
                let statusKey = statusArr[tag].statusKey
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
                
            } else if topIndicatorView.isHidden == false {
                
                let statusKey = hangoutsSearchResults[tag].statusKey
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
                
            } else if citiesIndicatorView.isHidden == false {
                
                let statusKey = statusSearchResults[tag].statusKey
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
                
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
    
    @IBAction func didPressTopChoiceBtn(_ sender: UIButton) {
        
        //if topIndicatorView.isHidden == false {
        topChoiceBtn.isEnabled = false
        profilesChoiceBtn.isEnabled = true
        citiesChoiceBtn.isEnabled = true
        //}
        
        topChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        topIndicatorView.isHidden = false
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = true
        
        hangoutsTableView.isHidden = false
        profilesTableView.isHidden = true
        statusesTableView.isHidden = true
        
        hangoutsSearchResults.removeAll()
        usersArr.append(currentUserInfo)
        
        if let searchText = searchBar.text {
            
            hangoutsSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    return false
                }
                
                let contentCheck = status.content as NSString
                let contentRange = contentCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                
                return contentRange.location != NSNotFound
                
            })
            
            self.hangoutsTableView.reloadData()
            
        }
        
        
        hangoutsTableView.rowHeight = UITableViewAutomaticDimension
        hangoutsTableView.estimatedRowHeight = 90
        
    }
    @IBAction func didPressProfilesChoiceBtn(_ sender: UIButton) {
        
        //if profilesIndicatorView.isHidden == false {
        topChoiceBtn.isEnabled = true
        profilesChoiceBtn.isEnabled = false
        citiesChoiceBtn.isEnabled = true
        //}
        
        topChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        topIndicatorView.isHidden = true
        profilesIndicatorView.isHidden = false
        citiesIndicatorView.isHidden = true
        
        hangoutsTableView.isHidden = true
        profilesTableView.isHidden = false
        statusesTableView.isHidden = true
        
        for index in 0..<usersArr.count {
            if usersArr[index].usersKey == currentUserInfo.usersKey {
                usersArr.remove(at: index)
                break
            }
        }
        
        profileSearchResults.removeAll()
        
        //        segmentChoice.tintColor = UIColor.white
        //        let segAttributes: NSDictionary = [
        //            NSForegroundColorAttributeName: UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)//,
        //            //NSFontAttributeName: UIFont(name: "Avenir-MediumOblique", size: 20)!
        //        ]
        //        segmentChoice.setTitleTextAttributes(segAttributes as? [AnyHashable : Any], for: .selected)
        
        if let searchText = searchBar.text {
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
            
            self.profilesTableView.reloadData()
            
        }
        
        hangoutsTableView.isHidden = true
        profilesTableView.isHidden = false
        statusesTableView.isHidden = true
        //        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //            self.usersArr = []
        //
        //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                for snap in snapshot {
        //                    //print("USERS: \(snap)")
        //                    if let usersDict = snap.value as? Dictionary<String, Any> {
        //                        let key = snap.key
        //                        let users = Users(usersKey: key, usersData: usersDict)
        //                        if let currentUser = Auth.auth().currentUser?.uid {
        //                            if currentUser == users.usersKey {
        //                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
        //                                    value as? String == "received"
        //                                }
        //                                if newFriend && users.friendsList["seen"] as? String == "false" {
        //                                    //self.footerNewFriendIndicator.isHidden = false
        //                                }
        //                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
        //                                    value as? String == "false"
        //                                }
        //                                if newJoin {
        //                                    //self.footerNewFriendIndicator.isHidden = false
        //                                }
        //                                self.currentUserInfo = users
        //
        //                            }
        //                        }
        //
        //                        self.usersArr.append(users)
        //
        //                        if let currentUser = Auth.auth().currentUser?.uid {
        //                            if users.usersKey == currentUser {
        //                                self.usersArr.removeLast()
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //            self.profilesTableView.reloadData()
        //
        //        })
        
    }
    @IBAction func didPressCitiesChoiceBtn(_ sender: UIButton) {
        
        //if citiesIndicatorView.isHidden == false {
        topChoiceBtn.isEnabled = true
        profilesChoiceBtn.isEnabled = true
        citiesChoiceBtn.isEnabled = false
        //}
        
        topChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        topChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        profilesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        topIndicatorView.isHidden = true
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = false
        
        hangoutsTableView.isHidden = true
        profilesTableView.isHidden = true
        statusesTableView.isHidden = false
        
        statusSearchResults.removeAll()
        usersArr.append(currentUserInfo)
        
        if let searchText = searchBar.text {
            
            statusSearchResults = statusArr.filter({ (status) -> Bool in
                
                if searchText == "" {
                    //statusesTableView.isScrollEnabled = false
                    return false
                }
                
                let cityCheck = status.city as NSString
                let cityRange = cityCheck.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return cityRange.location != NSNotFound
                
            })
            
            self.statusesTableView.reloadData()
            
        }
        
        
        statusesTableView.rowHeight = UITableViewAutomaticDimension
        statusesTableView.estimatedRowHeight = 90
        
        hangoutsTableView.isHidden = true
        profilesTableView.isHidden = true
        statusesTableView.isHidden = false
        
        //        DataService.ds.REF_STATUS.queryOrdered(byChild: "joinedNumber").observeSingleEvent(of: .value, with: { (snapshot) in
        //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                for snap in snapshot {
        //                    //print("STATUS: \(snap)")
        //                    if let statusDict = snap.value as? Dictionary<String, Any> {
        //                        let key = snap.key
        //                        let status = Status(statusKey: key, statusData: statusDict)
        //                        self.statusArr.insert(status, at: 0)
        //
        //                    }
        //                }
        //            }
        //            self.statusesTableView.reloadData()
        //        })
        //
        //        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //            self.usersArr = []
        //
        //            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
        //                for snap in snapshot {
        //                    //print("USERS: \(snap)")
        //                    if let usersDict = snap.value as? Dictionary<String, Any> {
        //                        let key = snap.key
        //                        let users = Users(usersKey: key, usersData: usersDict)
        //                        self.usersArr.append(users)
        //                    }
        //                }
        //            }
        //            self.statusesTableView.reloadData()
        //        })
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
        //delete
    }
}
