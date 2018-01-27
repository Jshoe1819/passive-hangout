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

class SearchProfilesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ExploreHangoutsDelegate, SearchProfilesDelegate, SearchCitiesDelegate {
    
    var usersArr = [Users]()
    var statusArr = [Status]()
    var currentUserInfo: Users!
    var searchActive = false
    var profileSearchResults = [Users]()
    var citySearchResults = [Status]()
    var joinedKeys = [String]()
    var unjoinedArr = [String]()
    var privateArr = [String]()
    var privateArrIds = [String]()
    var cityArr = [String]()
    var numberLoadMores = 1
    var searchText = ""
    var refreshControl: UIRefreshControl!
    var originController = ""
    
    @IBOutlet weak var exploreTableView: UITableView!
    @IBOutlet weak var profilesTableView: UITableView!
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var searchOptionsStackView: UIStackView!
    @IBOutlet weak var profilesChoiceBtn: UIButton!
    @IBOutlet weak var citiesChoiceBtn: UIButton!
    @IBOutlet weak var profilesIndicatorView: UIView!
    @IBOutlet weak var citiesIndicatorView: UIView!
    @IBOutlet weak var noResultsLbl: UILabel!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        refreshControl.addTarget(self, action: #selector(SearchProfilesVC.refresh(sender:)), for: .valueChanged)
        exploreTableView.addSubview(refreshControl)
        
        exploreTableView.delegate = self
        exploreTableView.dataSource = self
        profilesTableView.delegate = self
        profilesTableView.dataSource = self
        cityTableView.delegate = self
        cityTableView.dataSource = self
        
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor(red:0.53, green:0.32, blue:0.58, alpha:1)
        
        profilesTableView.keyboardDismissMode = .onDrag
        cityTableView.keyboardDismissMode = .onDrag
        
        noResultsLbl.isHidden = true
        noResultsLbl.alpha = 0.0
        
        searchBar.text = searchText
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        
                        if users.isPrivate == true {
                            self.privateArrIds.append(users.usersKey)
                        }
                        
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if currentUser == users.usersKey {
                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if newFriend && users.friendsList["seen"] as? String == "false" {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
                                    value as? String == "false"
                                }
                                if newJoin {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                
                                self.footerNewMsgIndicator.isHidden = !users.hasNewMsg
                                
                                self.currentUserInfo = users
                                
                            }
                            
                        }
                        
                        self.usersArr.append(users)
                    }
                }
            }
            self.exploreTableView.reloadData()
        })
        
        DataService.ds.REF_STATUS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.cityArr = []

            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let dict = snap.value as? Dictionary<String, Any> {
                        if let city = dict["city"] as? String {
                            if !self.cityArr.contains(city) {
                                self.cityArr.append(city)
                            }
                        }
                    }
                }
            }
            
        })
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if originController == "homeToSearch" || originController == "joinedListToSearch" {
            exploreTableView.frame.origin.x += 500
            exploreTableView.isHidden = false
            searchBar.frame.origin.x += 500
            searchBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.exploreTableView.frame.origin.x -= 500
                self.searchBar.frame.origin.x -= 500
            }
            
        } else if originController == "myProfileToSearch" || originController == "pastStatusesToSearch" || originController == "editProfileToSearch" || originController == "leaveFeedbackToSearch" || originController == "friendsListToSearch" || originController == "viewProfileToSearch" || originController == "joinedFriendsToSearch" {
            exploreTableView.frame.origin.x -= 500
            exploreTableView.isHidden = false
            searchBar.frame.origin.x -= 500
            searchBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.exploreTableView.frame.origin.x += 500
                self.searchBar.frame.origin.x += 500
            }
            
        } else {
            exploreTableView.isHidden = false
            searchBar.isHidden = false
            return
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == false {
            if statusArr.count == 0 {
                self.refresh(sender: self)
            }
            return statusArr.count
            
        } else if profilesIndicatorView.isHidden == false {
            return profileSearchResults.count
        }
        return citySearchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if searchActive == false {

            noResultsLbl.isHidden = true
            noResultsLbl.alpha = 0.0
            
            let status = statusArr[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "exploreHangouts") as? ExploreHangoutCell {
                
                if let currentUser = Auth.auth().currentUser?.uid {
                    
                    if status.userId == currentUser {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = true
                    } else {
                        print(joinedKeys.count)
                        print(unjoinedArr.count)
                        let join = status.joinedList.keys.contains { (key) -> Bool in
                            key == currentUser
                        }
                        if (join && !unjoinedArr.contains(status.statusKey)) || joinedKeys.contains(status.statusKey) {
                            cell.joinBtn.isHidden = true
                            cell.alreadyJoinedBtn.isHidden = false
                        } else {
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
            
        }
        
        if profilesIndicatorView.isHidden == false {

            if profileSearchResults.isEmpty {
                noResultsLbl.isHidden = false
                noResultsLbl.alpha = 1.0
                profilesTableView.isScrollEnabled = false
                return SearchProfilesCell() 
            } else {
                noResultsLbl.isHidden = true
                noResultsLbl.alpha = 0.0
                profilesTableView.isScrollEnabled = true
            }

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
            
            if citySearchResults.isEmpty {
                noResultsLbl.isHidden = false
                noResultsLbl.alpha = 1.0
                cityTableView.isScrollEnabled = false
            } else {
                noResultsLbl.isHidden = true
                noResultsLbl.alpha = 0.0
                cityTableView.isScrollEnabled = true
            }
            
            let status = citySearchResults[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCityCell") as? SearchCityCell {
                
                if let currentUser = Auth.auth().currentUser?.uid {
                    
                    if status.userId == currentUser {
                        cell.joinBtn.isHidden = true
                        cell.alreadyJoinedBtn.isHidden = true
                    } else {
                        
                        let join = status.joinedList.keys.contains { (key) -> Bool in
                            key == currentUser
                        }
                        if (join && !unjoinedArr.contains(status.statusKey)) || joinedKeys.contains(status.statusKey) {
                            cell.joinBtn.isHidden = true
                            cell.alreadyJoinedBtn.isHidden = false
                        } else{
                            cell.joinBtn.isHidden = false
                            cell.alreadyJoinedBtn.isHidden = true
                        }
                    }
                }
                
                cityTableView.rowHeight = UITableViewAutomaticDimension
                cityTableView.estimatedRowHeight = 120
                
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.tag = indexPath.row
                cell.configureCell(status: status, users: usersArr)
                
                return cell
            }
            
        }
        return SearchCityCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if profilesIndicatorView.isHidden == false {
            return 84
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func mutualFriendsSort(usersArr: [Users]) {
        for index in 0..<usersArr.count {
            let arrayKeys = Array(currentUserInfo.friendsList.keys)
            for friend in 0..<arrayKeys.count {
                let mutualFriend = usersArr[index].friendsList.keys.contains(arrayKeys[friend])
                if mutualFriend && arrayKeys[friend] != "seen" {
                    let element = self.usersArr.remove(at: index)
                    self.usersArr.insert(element, at: 0)
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if profilesIndicatorView.isHidden == false {
            let selectedProfileKey = profileSearchResults[indexPath.row].usersKey
            performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfileKey)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        searchActive = true
        exploreTableView.isHidden = true
        
        privateArr = []
        
        searchOptionsStackView.isHidden = false
        bottomSeparatorView.isHidden = false
        
        if profilesChoiceBtn.isEnabled == false {
            
            for index in 0..<usersArr.count {
                if usersArr[index].usersKey == currentUserInfo.usersKey {
                    usersArr.remove(at: index)
                    break
                }
            }
            
            profilesIndicatorView.isHidden = false
            profilesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
            profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
            
        } else if citiesChoiceBtn.isEnabled == false {
            
            citiesIndicatorView.isHidden = false
            citiesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
            citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
            
        }
        
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
        
        exploreTableView.isHidden = false
        profilesTableView.isHidden = true
        cityTableView.isHidden = true
        
        searchOptionsStackView.isHidden = true
        bottomSeparatorView.isHidden = true
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = true
        
        noResultsLbl.isHidden = true
        noResultsLbl.alpha = 0.0
        
        profileSearchResults.removeAll()
        citySearchResults.removeAll()
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        profilesTableView.reloadData()
        cityTableView.reloadData()
        
        if profilesIndicatorView.isHidden == false {
            profileSearchResults.removeAll()
            profilesTableView.reloadData()
        } else if citiesIndicatorView.isHidden == false {
            citySearchResults.removeAll()
            cityTableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if profilesIndicatorView.isHidden == false {
            
            profilesTableView.isHidden = false

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
            
            if profileSearchResults.count == 0 && searchText != "" {
                noResultsLbl.isHidden = false
                UIView.animate(withDuration: 0.75) {
                    self.noResultsLbl.alpha = 1.0
                    self.noResultsLbl.isHidden = false
                }
            } else {
                noResultsLbl.isHidden = true
                noResultsLbl.alpha = 0.0
            }
            
            self.profilesTableView.reloadData()
            
        } else if citiesIndicatorView.isHidden == false {
            
            cityTableView.isHidden = false

            let possibleCities = cityArr.filter { $0.contains("\(searchText.lowercased())") }
            
            self.citySearchResults = []
            
            for city in possibleCities {
                
                DataService.ds.REF_STATUS.queryOrdered(byChild: "city").queryEqual(toValue: "\(city)").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            
                            if let statusDict = snap.value as? Dictionary<String, Any> {
                                let key = snap.key
                                let status = Status(statusKey: key, statusData: statusDict)

                                if !self.privateArrIds.contains(status.userId) {
                                    self.citySearchResults.insert(status, at: 0)
                                }
                            }
                        }
                    }
                    
                    self.cityTableView.reloadData()
                })
            }
            
            
            if citySearchResults.count == 0 && searchText != "" {
                noResultsLbl.isHidden = false
                UIView.animate(withDuration: 0.75) {
                    self.noResultsLbl.alpha = 1.0
                    self.noResultsLbl.isHidden = false
                }
            } else {
                noResultsLbl.isHidden = true
                noResultsLbl.alpha = 0.0
            }
            
            self.cityTableView.reloadData()
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchToViewProfile" {
            if let nextVC = segue.destination as? ViewProfileVC {
                nextVC.selectedProfileKey = sender as! String
                nextVC.originController = "searchToViewProfile"
                nextVC.showFooterIndicator = !footerNewFriendIndicator.isHidden
                nextVC.showFooterNewMsg = !footerNewMsgIndicator.isHidden
                if let text = searchBar.text {
                    nextVC.searchText = text
                }
            }
        } else if segue.identifier == "searchToHome" {
            if let nextVC = segue.destination as? ActivityFeedVC {
                nextVC.originController = "searchToHome"
            }
        } else if segue.identifier == "searchToMyProfile" {
            if let nextVC = segue.destination as? ProfileVC {
                nextVC.originController = "searchToMyProfile"
            }
        } else if segue.identifier == "searchToJoinedList" {
            if let nextVC = segue.destination as? JoinedListVC {
                nextVC.originController = "searchToJoinedList"
            }
        }
    }
    
    func didPressProfilePic(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                
                let userKey = statusArr[tag].userId
                
                if userKey == currentUser {
                    return
                }
                
                for index in 0..<usersArr.count {
                    if userKey == usersArr[index].usersKey {
                        let selectedProfileKey = usersArr[index].usersKey
                        performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfileKey)
                    }
                }
                
            }
                
            else if citiesIndicatorView.isHidden == false {
                let userKey = citySearchResults[tag].userId
                if userKey == currentUser {
                    return
                }
                
                for index in 0..<usersArr.count {
                    if userKey == usersArr[index].usersKey {
                        let selectedProfileKey = usersArr[index].usersKey
                        performSegue(withIdentifier: "searchToViewProfile", sender: selectedProfileKey)
                    }
                }
            }
        }
    }
    
    func didPressJoinBtn(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                
                let statusKey = statusArr[tag].statusKey
                let userKey = statusArr[tag].userId
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
                DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count])
                
                joinedKeys.append(statusKey)
                
                for index in 0..<unjoinedArr.count {
                    if unjoinedArr[index] == statusKey {
                        unjoinedArr.remove(at: index)
                        break
                    }
                }
                
            }
                
            else if citiesIndicatorView.isHidden == false {
                
                let statusKey = citySearchResults[tag].statusKey
                let userKey = citySearchResults[tag].userId
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").updateChildValues([statusKey: "true" ])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues([currentUser: "true"])
                DataService.ds.REF_USERS.child(userKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").updateChildValues(["seen": "false"])
                DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : citySearchResults[tag].joinedList.count])
                
                joinedKeys.append(statusKey)
                
                for index in 0..<unjoinedArr.count {
                    if unjoinedArr[index] == statusKey {
                        unjoinedArr.remove(at: index)
                        break
                    }
                }
                
            }
        }
    }
    
    func didPressAlreadyJoinedBtn(_ tag: Int) {
        if let currentUser = Auth.auth().currentUser?.uid {
            
            if searchActive == false {
                
                let statusKey = statusArr[tag].statusKey
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : statusArr[tag].joinedList.count-1])
                
                unjoinedArr.append(statusKey)
                
                for index in 0..<joinedKeys.count {
                    if joinedKeys[index] == statusKey {
                        joinedKeys.remove(at: index)
                        break
                    }
                }
                
            } else if citiesIndicatorView.isHidden == false {
                
                let statusKey = citySearchResults[tag].statusKey
                DataService.ds.REF_USERS.child(currentUser).child("joinedList").child(statusKey).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).child("joinedList").child(currentUser).removeValue()
                DataService.ds.REF_STATUS.child(statusKey).updateChildValues(["joinedNumber" : citySearchResults[tag].joinedList.count-1])
                
                unjoinedArr.append(statusKey)
                
                for index in 0..<joinedKeys.count {
                    if joinedKeys[index] == statusKey {
                        joinedKeys.remove(at: index)
                        break
                    }
                }
                
            }
        }
    }
    
    func didPressAddFriendBtn(_ tag: Int) {
        
        let friendKey = profileSearchResults[tag].usersKey
        
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").updateChildValues([friendKey: "sent"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues([currentUserInfo.usersKey: "received"])
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").updateChildValues(["seen": "false"])
    }
    
    func didPressRequestSentBtn(_ tag: Int) {
        
        let friendKey = profileSearchResults[tag].usersKey
        
        DataService.ds.REF_USERS.child(currentUserInfo.usersKey).child("friendsList").child(friendKey).removeValue()
        DataService.ds.REF_USERS.child(friendKey).child("friendsList").child(currentUserInfo.usersKey).removeValue()
    }
    
    @IBAction func didPressProfilesChoiceBtn(_ sender: UIButton) {

        profilesChoiceBtn.isEnabled = false
        citiesChoiceBtn.isEnabled = true
        
        profilesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        profilesIndicatorView.isHidden = false
        citiesIndicatorView.isHidden = true
        
        profilesTableView.isHidden = false
        cityTableView.isHidden = true
        
        for index in 0..<usersArr.count {
            if usersArr[index].usersKey == currentUserInfo.usersKey {
                usersArr.remove(at: index)
                break
            }
        }
        
        profileSearchResults.removeAll()
        privateArr = []
        mutualFriendsSort(usersArr: usersArr)
        
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
        
        profilesTableView.isHidden = false
        cityTableView.isHidden = true
        
    }
    @IBAction func didPressCitiesChoiceBtn(_ sender: UIButton) {

        profilesChoiceBtn.isEnabled = true
        citiesChoiceBtn.isEnabled = false
        
        profilesChoiceBtn.setTitleColor(UIColor.lightGray, for: .normal)
        profilesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
        
        citiesChoiceBtn.setTitleColor(UIColor(red:0.53, green:0.32, blue:0.58, alpha:1), for: .normal)
        citiesChoiceBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        profilesIndicatorView.isHidden = true
        citiesIndicatorView.isHidden = false
        
        profilesTableView.isHidden = true
        cityTableView.isHidden = false
        
        citySearchResults.removeAll()
        privateArr = []
        usersArr.append(currentUserInfo)
        
        if let searchText = searchBar.text {
            
            let possibleCities = cityArr.filter { $0.contains("\(searchText.lowercased())") }
            
            self.citySearchResults = []
            
            for city in possibleCities {
                
                DataService.ds.REF_STATUS.queryOrdered(byChild: "city").queryEqual(toValue: "\(city)").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            
                            if let statusDict = snap.value as? Dictionary<String, Any> {
                                let key = snap.key
                                let status = Status(statusKey: key, statusData: statusDict)
                                
                                if !self.privateArrIds.contains(status.userId) {
                                    self.citySearchResults.insert(status, at: 0)
                                }
                            }
                        }
                    }
                    
                    self.cityTableView.reloadData()
                })
            }
            
            
            if citySearchResults.count == 0 && searchText != "" {
                noResultsLbl.isHidden = false
                UIView.animate(withDuration: 0.75) {
                    self.noResultsLbl.alpha = 1.0
                    self.noResultsLbl.isHidden = false
                }
            } else {
                noResultsLbl.isHidden = true
                noResultsLbl.alpha = 0.0
            }
        }
        
        
        cityTableView.rowHeight = UITableViewAutomaticDimension
        cityTableView.estimatedRowHeight = 90
        
        profilesTableView.isHidden = true
        cityTableView.isHidden = false
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == statusArr.count && (statusArr.count + privateArr.count) >= 10 * numberLoadMores {
            loadMore()
        }
    }
    
    func loadMore() {
        self.numberLoadMores += 1

        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").queryLimited(toLast: UInt(10 * numberLoadMores)).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        
                        if !self.privateArrIds.contains(status.userId) {
                            self.statusArr.insert(status, at: 0)
                        } else {
                            self.privateArr.append(status.statusKey)
                        }
                    }
                }
            }
            
            self.exploreTableView.reloadData()
        })
        
    }
    
    func refresh(sender: Any) {

        numberLoadMores = 1
        
        unjoinedArr = []
        joinedKeys = []
        
        DataService.ds.REF_STATUS.queryOrdered(byChild: "postedDate").queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.statusArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                    if let statusDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let status = Status(statusKey: key, statusData: statusDict)
                        if !self.privateArrIds.contains(status.userId) {
                            self.statusArr.insert(status, at: 0)
                        } else {
                            self.privateArr.append(status.statusKey)
                        }
                    }
                }
            }
            
            self.exploreTableView.reloadData()
        })
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.usersArr = []
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                    if let usersDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let users = Users(usersKey: key, usersData: usersDict)
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if currentUser == users.usersKey {
                                let newFriend = users.friendsList.values.contains { (value) -> Bool in
                                    value as? String == "received"
                                }
                                if newFriend && users.friendsList["seen"] as? String == "false" {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                let newJoin = users.joinedList.values.contains { (value) -> Bool in
                                    value as? String == "false"
                                }
                                if newJoin {
                                    self.footerNewFriendIndicator.isHidden = false
                                }
                                self.currentUserInfo = users
                                
                            }
                        }
                        self.usersArr.append(users)
                    }
                }
            }
            self.exploreTableView.reloadData()
        })
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.refreshControl.endRefreshing()
        }
    }
    
}
