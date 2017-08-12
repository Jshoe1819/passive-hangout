//
//  LoginVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToActivityFeed", sender: self)
        
    }
    
    @IBAction func createAccountBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "createAccount", sender: self)
    }
    
    @IBAction func facebookLoginBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToActivityFeed", sender: self)
    }
}
