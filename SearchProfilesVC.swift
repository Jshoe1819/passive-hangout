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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.keyboardAppearance = .dark
        tableView.keyboardDismissMode = .onDrag
        
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
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = usersArr.filter({ (user) -> Bool in
            
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
            cell.configureCell(user: user, currentUser: currentUserInfo)
            return cell
        }
        return SearchProfilesCell()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressAddFriendBtn(_ tag: Int) {
        print(tag)
        //tableView.reloadData()
    }
    
    func didPressRequestSentBtn(_ tag: Int) {
        print(tag)
        //tableView.reloadData()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "searchToHome", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
    }
    @IBAction func joinedListBtnPressed(_ sender: Any) {
    }
    @IBAction func myProfileBtnPressed(_ sender: Any) {
    }
}
