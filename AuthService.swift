//
//  AuthService.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/14/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

typealias Completion = (_ errMsg: String?, _ data: Any?) -> Void

class AuthService {
    
    private static let _aus = AuthService()
    
    static var aus: AuthService {
        return _aus
    }
    
    func sendPasswordReset(email: String, onComplete: Completion?) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                onComplete?("All Good", nil)
            }
        }
    }
    
    func login(email: String, password: String, onComplete: Completion?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                if let user = user {
                    onComplete?("All Good", user.uid)
                }
            }
        }
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        //print(error.debugDescription)
        if let errCode = AuthErrorCode(rawValue: error.code) {
            switch errCode {
            case .userNotFound:
                onComplete?("No account found with this email", nil)
            //self.errorAlert.text = "No account found with this email"
            case .tooManyRequests:
                onComplete?("Too many login attempts, please try again later", nil)
            //self.errorAlert.text = "Too many login attempts, please try again later"
            case .invalidEmail:
                onComplete?("Invalid email format", nil)
            //self.errorAlert.text = "Invalid email format"
            case .userDisabled:
                onComplete?("Account has been disabled", nil)
            //self.errorAlert.text = "Account has been disabled"
            case .wrongPassword:
                onComplete?("Wrong password", nil)
            //self.errorAlert.text = "Wrong password"
            default:
                onComplete?("Error: \(error)", nil)
                //print("Login user error: \(error!)")
            }
        }
    }
}
