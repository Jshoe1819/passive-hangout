//
//  SignUpVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/11/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftKeychainWrapper


class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    
    var userKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.confirmPasswordField.delegate = self
        
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key
                    self.userKeys.append(key)
                }
            }
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            confirmPasswordField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpBackBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "backToLogin", sender: self)
    }
    
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        
        if let name = nameField.text {
            if name == "" {
                errorAlert.text = "Please enter your name"
            } else {
                if let email = emailField.text {
                    if email == "" {
                        errorAlert.text = "Please enter an email address"
                    } else {
                        if let password = passwordField.text {
                            if password == "" {
                                errorAlert.text = "Please enter a password"
                            } else {
                                if password.count < 6 {
                                    errorAlert.text = "Password must be at least six characters"
                                } else {
                                    if let passwordConfirm = confirmPasswordField.text {
                                        if passwordConfirm.count == 0 {
                                            errorAlert.text = "Please confirm password"
                                        } else if password != passwordConfirm {
                                            errorAlert.text = "Passwords do not match"
                                        } else {
                                            
                                            AuthService.aus.createUser(email: email, password: password, onComplete: { (errMsg, uid) in
                                                if errMsg == "All Good" {
                                                    
                                                    if let uid = uid {
                                                        let userData = ["name":"\(self.nameField.text!)",
                                                            "email":"\(self.emailField.text!)",
                                                            "statusId": ["a":true],
                                                            "friendsList": ["seen": true],
                                                            "joinedList": ["seen": true],
                                                            "id": "a",
                                                            "cover": ["source":"gs://passive-hangout.appspot.com/background-pictures/default-background.png"],
                                                            "profilePicUrl":"gs://passive-hangout.appspot.com/profile-pictures/default-profile.png",
                                                            "hasNewMsg":false,
                                                            "isPrivate":false,
                                                            "occupation":"",
                                                            "employer":"",
                                                            "currentCity":"",
                                                            "school":""] as [String : Any]
                                                        self.completeSignIn(uid: uid as! String)
                                                        DataService.ds.createFirebaseDBUser(uid: uid as! String, userData: userData)
                                                        
                                                    }
                                                    
                                                } else {
                                                    self.errorAlert.text = errMsg
                                                }
                                            })
                                        }
                                    }
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
                //Handle error?
            } else if result?.isCancelled == true {
                self.errorAlert.text = "Facebook sign up cancelled"
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
        self.performSegue(withIdentifier: "signUpToEditProfile", sender: nil)
    }
    
}
