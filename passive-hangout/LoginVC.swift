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

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorAlert: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        //press forgot password brings up prompt for email and send, call function
        //forgotPasswordLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendPasswordReset(withEmail:completion:))))
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginBtnPressed(self)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //TESTTTT
    @IBAction func testForgot(_ sender: Any) {
        
        Auth.auth().sendPasswordReset(withEmail: "jshoe1819@gmail.com") { (error) in
            if error != nil {
                print(error!)
            } else {
                print("woo sent")
            }
        }

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
                let userData = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,cover"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                if let userData = userData {
                    userData.start(completionHandler: { (connection, result, error) -> Void in
                        if error != nil {
                            print("error: \(error!)")
                        } else {
                            //add other data to data where result is?
                            let data: [String: Any] = result as! [String: Any]
                            //data["school"] = "yo"
                            
                            //                        let userData = ["name":"\(self.nameField.text!)",
                            //                            "email":"\(self.emailField.text!)",
                            //                            "statusId": ["a":true],
                            //                            "friendsList": ["seen": true],
                            //                            "joinedList": ["seen": true],
                            //                            "id": "a",
                            //                            "cover": ["source":"gs://passive-hangout.appspot.com/cover-pictures/default-cover.jpg"],
                            //                            "profilePicUrl":"gs://passive-hangout.appspot.com/profile-pictures/default-profile.png",
                            //                            "hasNewMsg":false,
                            //                            "isPrivate":false,
                            //                            "occupation":"",
                            //                            "employer":"",
                            //                            "currentCity":"",
                            //                            "school":""] as [String : Any]
                            
                            
                            print(data)
                            self.firebaseCredentialAuth(credential, userData: data)
                        }
                    })}
            }
        }
    }
    
    func firebaseCredentialAuth(_ credential: AuthCredential, userData: Dictionary<String, Any>) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JAKE: Can't auth with credential passed to firebase - \(error!)")
            } else {
                print("JAKE: Successfull passed credential for firebase auth")
                if let user = user {
                    self.completeSignIn(uid: user.uid)
                    
                    //restricts to one data load?
                    if let currentUser = Auth.auth().currentUser?.uid {
                        if user.uid == currentUser {
                            return
                        }
                    }
                    
                    DataService.ds.createFirebaseDBUser(uid: user.uid, userData: userData)
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
