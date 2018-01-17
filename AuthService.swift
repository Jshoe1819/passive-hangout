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
    
    func createUser(email: String, password: String, onComplete: Completion?) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
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

        if let errCode = AuthErrorCode(rawValue: error.code) {
            switch errCode {
            case .userNotFound:
                onComplete?("No account found with this email", nil)
            case .tooManyRequests:
                onComplete?("Too many login attempts, please try again later", nil)
            case .invalidEmail:
                onComplete?("Invalid email format", nil)
            case .userDisabled:
                onComplete?("Account has been disabled", nil)
            case .wrongPassword:
                onComplete?("Wrong password", nil)
            case .emailAlreadyInUse:
                onComplete?("Account already exists with this email", nil)
            default:
                onComplete?("Error: \(error)", nil)
            }
        }
    }
}
