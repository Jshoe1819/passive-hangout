//
//  LoginVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftKeychainWrapper

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            self.performSegue(withIdentifier: "loginToActivityFeed", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        //login logic - firebase
        if let email = emailField.text {
            if email == "" {
                errorAlert.text = "Please enter an email address"
            } else {
                if let password = passwordField.text {
                    if password == "" {
                        errorAlert.text = "Please enter a password"
                    } else {
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let errCode = AuthErrorCode(rawValue: error!._code) {
                                    switch errCode {
                                    case .userNotFound:
                                        self.errorAlert.text = "No account found with this email"
                                    case .tooManyRequests:
                                        self.errorAlert.text = "Too many login attempts, please try again later"
                                    case .invalidEmail:
                                        self.errorAlert.text = "Invalid email format"
                                    case .userDisabled:
                                        self.errorAlert.text = "Account has been disabled"
                                    case .wrongPassword:
                                        self.errorAlert.text = "Wrong password"
                                    default:
                                        print("Login user error: \(error!)")
                                    }
                                }
                            }else {
                                print("Successful login")
                                self.errorAlert.text = " "
                                if let user = user {
                                self.completeSignIn(uid: user.uid)
                                }
                            }})
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func createAccountBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "createAccount", sender: self)
    }
    
    @IBAction func facebookLoginBtnPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if error != nil {
                print("JAKE: Can't auth with facebook - \(error!)")
            } else if result?.isCancelled == true {
                self.errorAlert.text = "Facebook login cancelled"
            } else {
                self.errorAlert.text = " "
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseCredentialAuth(credential)
            }
        }
    }
    
    func firebaseCredentialAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JAKE: Can't auth with credential passed to firebase - \(error!)")
            } else {
                print("JAKE: Successfull passed credential for firebase auth")
                if let user = user {
                self.completeSignIn(uid: user.uid)
                }
            }
        }
    }
    
    func completeSignIn(uid: String) {
        KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        self.performSegue(withIdentifier: "loginToActivityFeed", sender: self)
        print("JAKE: keychain saved")
    }
}
