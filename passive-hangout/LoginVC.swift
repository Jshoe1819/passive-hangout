//
//  LoginVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        //login logic - firebase
        if let email = emailField.text {
            if email == "" {
                errorAlert.isHidden = false
                errorAlert.text = "JAKE: Please enter email"
            } else {
                if let password = passwordField.text {
                    if password == "" {
                        errorAlert.isHidden = false
                        errorAlert.text = "JAKE: Please enter a password"
                    } else {
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            self.errorAlert.isHidden = true
                            self.performSegue(withIdentifier: "loginToActivityFeed", sender: self)
                        })
                }
                    
                }
                
            }
            
        }
        
    }
    
        @IBAction func createAccountBtnPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "createAccount", sender: self)
        }
        
        @IBAction func facebookLoginBtnPressed(_ sender: Any) {
            performSegue(withIdentifier: "loginToActivityFeed", sender: self)
        }
}
