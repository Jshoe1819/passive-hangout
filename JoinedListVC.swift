//
//  JoinedListVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/30/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class JoinedListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var statusArr = [Status]()
    var usersArr = [Users]()
    var currentUser: Users!
    var joinedList = [Status]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        for keys in 0..<statusArr.count {
            let join = currentUser.joinedList.keys.contains { (key) -> Bool in
                key == statusArr[keys].statusKey
            }
            if join {
                print("JAKE hi")
                joinedList.append(statusArr[keys])
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return joinedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = joinedList[indexPath.row]
        let users = usersArr
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedListCell") as? JoinedListCell {
            cell.configureCell(status: status, users: users)
            return cell
        } else {
            return JoinedListCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func homeBtnPressed(_ sender: Any) {
    }
    @IBAction func joinedBtnPressed(_ sender: Any) {
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
    }
    
    
}
