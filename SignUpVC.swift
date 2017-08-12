//
//  SignUpVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 8/11/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
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
    }
    
    @IBAction func signUpWithFacebookBtnPressed(_ sender: Any) {
    }
    
}
