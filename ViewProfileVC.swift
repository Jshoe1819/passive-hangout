//
//  ViewProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/28/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class ViewProfileVC: UIViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var lastStatusLbl: UILabel!
    @IBOutlet weak var statusAgeLbl: UILabel!
    @IBOutlet weak var privateImg: UIImageView!
    @IBOutlet weak var staticStackView: UIStackView!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var occupationLbl: UILabel!
    @IBOutlet weak var employerLbl: UILabel!
    @IBOutlet weak var currentCityLbl: UILabel!
    @IBOutlet weak var schoolLbl: UILabel!
    @IBOutlet weak var seePastStatusesBtn: RoundedButton!
    @IBOutlet weak var sendMessageBtn: RoundedButton!
    @IBOutlet weak var removeFriendBtn: RoundedButton!
    @IBOutlet weak var addFriendBtn: RoundedButton!
    @IBOutlet weak var addFriendTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func seePastStatusesBtnPressed(_ sender: Any) {
    }
    @IBAction func sendMessageBtnPressed(_ sender: Any) {
    }
    @IBAction func removeFriendBtnPressed(_ sender: Any) {
    }
    @IBAction func addFriendBtnPressed(_ sender: Any) {
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToFriendsList", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToHome", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewProfileToMyProfile", sender: nil)
    }

}
