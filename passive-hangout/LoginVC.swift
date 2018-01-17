//
//  LoginVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/8/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftKeychainWrapper

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    @IBOutlet weak var forgotPasswordView: UIView!
    @IBOutlet weak var forgotPasswordBackgroundBtn: UIButton!
    @IBOutlet weak var emailResetTextField: UITextField!
    @IBOutlet weak var confirmEmailResetTextfield: UITextField!
    @IBOutlet weak var confirmEmailErrorLbl: UILabel!
    
    var userKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.emailResetTextField.delegate = self
        self.confirmEmailResetTextfield.delegate = self
        
        forgotPasswordLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showForgotPasswordView)))
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key
                    self.userKeys.append(key)
                }
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            self.performSegue(withIdentifier: "loginToActivityFeed", sender: self)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginBtnPressed(self)
        } else if textField == emailResetTextField {
            confirmEmailResetTextfield.becomeFirstResponder()
        } else if textField == confirmEmailResetTextfield {
            confirmEmailResetTextfield.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showForgotPasswordView() {
        
        emailResetTextField.text = ""
        confirmEmailResetTextfield.text = ""
        confirmEmailErrorLbl.text = ""
        
        forgotPasswordView.frame.origin.x += 500
        forgotPasswordView.isHidden = false
        forgotPasswordBackgroundBtn.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.forgotPasswordView.frame.origin.x = 38.5
        }
        
    }
    
    @IBAction func sendResetBtnPressed(_ sender: Any) {
        
        if let resetEmail = emailResetTextField.text {
            if resetEmail == "" {
                confirmEmailErrorLbl.text = "Please enter an email address"
            } else {
                if let confirmEmail = confirmEmailResetTextfield.text {
                    if confirmEmail == "" {
                        confirmEmailErrorLbl.text = "Please confirm email"
                    } else if resetEmail != confirmEmail {
                        confirmEmailErrorLbl.text = "Emails do not match"
                    } else {
                        
                        AuthService.aus.sendPasswordReset(email: resetEmail, onComplete: { (errMsg, nil) in
                            
                            if errMsg == "All Good" {
                                
                                UIView.animate(withDuration: 0.5) {
                                    self.forgotPasswordView.frame.origin.x += 500
                                }
                                
                                let when = DispatchTime.now() + 0.5
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    self.forgotPasswordView.isHidden = true
                                    self.forgotPasswordBackgroundBtn.isHidden = true
                                    self.emailResetTextField.resignFirstResponder()
                                    self.confirmEmailResetTextfield.resignFirstResponder()
                                }
                                
                            } else {
                                self.confirmEmailErrorLbl.text = errMsg
                            }
                        })
                    }
                    
                }
                
            }
            
        }
        
    }
    @IBAction func cancelResetBtnPressed(_ sender: Any) {
        
        resignFirstResponder()
        
        UIView.animate(withDuration: 0.5) {
            self.forgotPasswordView.frame.origin.x += 500
        }
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.forgotPasswordView.isHidden = true
            self.forgotPasswordBackgroundBtn.isHidden = true
        }
        
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if let email = emailField.text {
            if email == "" {
                errorAlert.text = "Please enter an email address"
            } else {
                if let password = passwordField.text {
                    if password == "" {
                        errorAlert.text = "Please enter a password"
                    } else {
                        
                        AuthService.aus.login(email: email, password: password, onComplete: { (errMsg, uid) in
                            if errMsg == "All Good" {
                                self.completeSignIn(uid: uid as! String)
                            } else {
                                self.errorAlert.text = errMsg
                            }
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
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if error != nil {
                //Handle error?
            } else if result?.isCancelled == true {
                self.errorAlert.text = "Facebook login cancelled"
            } else {
                self.errorAlert.text = " "
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                let userData = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,cover"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                if let userData = userData {
                    userData.start(completionHandler: { (connection, result, error) -> Void in
                        if error != nil {
                            //Handle error?
                        } else {
                            let data: [String: Any] = result as! [String: Any]
                            self.firebaseCredentialAuth(credential, userData: data)
                        }
                    })}
            }
        }
    }
    
    func firebaseCredentialAuth(_ credential: AuthCredential, userData: Dictionary<String, Any>) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                //Handle error?
            } else {
                
                if let user = user {
                    self.completeSignIn(uid: user.uid)
                    
                    var data = userData
                    data["statusId"] = ["a":true]
                    data["friendsList"] = ["seen": true]
                    data["joinedList"] = ["seen": true]
                    data["hasNewMsg"] = false
                    data["isPrivate"] = false
                    data["occupation"] = ""
                    data["employer"] = ""
                    data["currentCity"] = ""
                    data["school"] = ""
                    
                    if let currentUser = Auth.auth().currentUser?.uid {
                        if self.userKeys.contains(currentUser) {
                            return
                        }
                    }
                    DataService.ds.createFirebaseDBUser(uid: user.uid, userData: data)
                }
            }
        }
    }
    
    func completeSignIn(uid: String) {
        KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        self.performSegue(withIdentifier: "loginToActivityFeed", sender: self)
    }
}
