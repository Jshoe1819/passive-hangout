//
//  SignUpVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/11/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpBackBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "backToLogin", sender: self)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        
        //username logic, check current users
        
        if let email = emailField.text {
            if email == "" {
                errorAlert.isHidden = false
                errorAlert.text = "JAKE: Please enter email"
            } else {
                if validateEmail(emailStr: email) {
                    if let password = passwordField.text {
                        if password == "" {
                            errorAlert.isHidden = false
                            errorAlert.text = "JAKE: Please enter a password"
                        } else {
                            if password.characters.count < 6 {
                                errorAlert.isHidden = false
                                errorAlert.text = "JAKE: Password must be at least six characters"
                            } else {
                                if let passwordConfirm = confirmPasswordField.text {
                                    if password == passwordConfirm {
                                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                            self.performSegue(withIdentifier: "signUpToActivityFeed", sender: self)
                                        })
                                    } else {
                                        errorAlert.isHidden = false
                                        errorAlert.text = "JAKE Passwords do not match"
                                    }
                                }
                                
                            }
                        }
                    }
                } else {
                    errorAlert.isHidden = false
                    errorAlert.text = "JAKE: Invalid email"
                }
            }
        }
        
    }
    
    @IBAction func signUpWithFacebookBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "signUpToActivityFeed", sender: self)
    }
    
    func validateEmail(emailStr: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: emailStr)
    }
    
}
