//
//  SignUpVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/11/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit


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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpBackBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "backToLogin", sender: self)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        
        //username logic needed, will tackle after sign in and sign up functional (database concern)
        
        if let email = emailField.text {
            if email == "" {
                errorAlert.text = "Please enter an email address"
            } else {
                if let password = passwordField.text {
                    if password == "" {
                        errorAlert.text = "Please enter a password"
                    } else {
                        if password.characters.count < 6 {
                            errorAlert.text = "Password must be at least six characters"
                        } else {
                            if let passwordConfirm = confirmPasswordField.text {
                                if passwordConfirm.characters.count == 0 {
                                    errorAlert.text = "Please confirm password"
                                } else if password == passwordConfirm {
                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                        if error != nil {
                                            if let errCode = AuthErrorCode(rawValue: error!._code) {
                                                switch errCode {
                                                case .invalidEmail:
                                                    self.errorAlert.text = "Invalid email format"
                                                case .emailAlreadyInUse:
                                                    self.errorAlert.text = "Account already exists with this email"
                                                default:
                                                    print("Create user error: \(error!)")
                                                }
                                            }
                                        } else {
                                            print("JAKE: New User Created")
                                            self.errorAlert.text = " "
                                            self.performSegue(withIdentifier: "signUpToActivityFeed", sender: self)
                                        }})
                                } else {
                                    errorAlert.text = "Passwords do not match"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func signUpWithFacebookBtnPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if error != nil {
                print("JAKE: Can't auth with facebook - \(error!)")
            } else if result?.isCancelled == true {
                self.errorAlert.text = "Facebook sign up cancelled"
            } else {
                self.errorAlert.text = " "
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseCredentialAuth(credential)
                self.performSegue(withIdentifier: "signUpToActivityFeed", sender: self)
            }
        }
        
    }
    
    func firebaseCredentialAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JAKE: Can't auth with credential passed to firebase - \(error!)")
            } else {
                print("JAKE: Successfull passed credential for firebase auth")
            }
        }
    }
    
    //    func validateEmail(emailStr: String) -> Bool {
    //        let REGEX: String
    //        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    //        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: emailStr)
    //    }
    
}
