//
//  EditProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/21/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EditProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var occupationTextField: UITextField!
    @IBOutlet weak var employerTextField: UITextField!
    @IBOutlet weak var currentCityTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var privateProfileSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        occupationTextField.delegate = self
        employerTextField.delegate = self
        currentCityTextField.delegate = self
        schoolTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == occupationTextField {
            occupationTextField.resignFirstResponder()
        } else if textField == employerTextField {
            employerTextField.resignFirstResponder()
        } else if textField == currentCityTextField {
            currentCityTextField.resignFirstResponder()
        } else if textField == schoolTextField {
            schoolTextField.resignFirstResponder()
        }
        return true
    }
    
    
    
    func setPrivate(privateSwitch: UISwitch) -> Bool {
        if privateSwitch.isOn {
            return true
        } else {
            return false
        }
    }
    
//    @IBAction func occupationBtnPressed(_ sender: Any) {
//        occupationTextField.isEnabled = true
//        occupationBtn.isHidden = true
//        occupationTextField.becomeFirstResponder()
//        //occupationTextField.sizeToFit()
//        //occupationTextField.adjustsFontSizeToFitWidth = true
//        //occupationTextField.minimumFontSize = 8.0
//        
//    }

    @IBAction func saveBtnPressed(_ sender: Any) {
        print(setPrivate(privateSwitch: privateProfileSwitch))
        performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToHome", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
    }
    
}
