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
import FirebaseStorage
import Kingfisher

class EditProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var imagePicked = 0
    var toBeDeletedProfRef = ""
    var toBeDeletedCoverRef = ""
    
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var profileImg: FeedProfilePic!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var currentCityTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var employerTextField: UITextField!
    @IBOutlet weak var occupationTextField: UITextField!
    @IBOutlet weak var privateProfileSwitch: UISwitch!
    @IBOutlet weak var profileImgPicker: UIButton!
    @IBOutlet weak var coverImgPicker: UIButton!
    @IBOutlet weak var footerNewFriendIndicator: UIView!
    @IBOutlet weak var footerNewMsgIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        nameTextField.delegate = self
        currentCityTextField.delegate = self
        schoolTextField.delegate = self
        employerTextField.delegate = self
        occupationTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let currentUser = Auth.auth().currentUser?.uid {
            DataService.ds.REF_USERS.child("\(currentUser)").observe(.value, with: { (snapshot) in
                //print("USERS: \(snapshot)")
                if let currentUserData = snapshot.value as? Dictionary<String, Any> {
                    let user = Users(usersKey: currentUser, usersData: currentUserData)
                    let answer = user.friendsList.values.contains { (value) -> Bool in
                        value as? String == "received"
                    }
                    if answer && user.friendsList["seen"] as? String == "false" {
                        self.footerNewFriendIndicator.isHidden = false
                    }
                    self.footerNewMsgIndicator.isHidden = !user.hasNewMsg
                    
                    self.toBeDeletedProfRef = user.profilePicUrl
                    //print("1: \(self.toBeDeletedProfRef)")
                    self.toBeDeletedCoverRef = user.cover["source"] as! String
                    //print(self.toBeDeletedCoverRef)
                    self.populateProfilePicture(user: user)
                    //print(user.cover["source"])
                    self.populateCoverPicture(user: user)
                    self.populateInformation(user: user)
                    self.toBeDeletedProfRef = user.profilePicUrl
                    self.toBeDeletedCoverRef = user.cover["source"] as! String
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            if imagePicked == 1 {
                profileImg.image = image
                profileImg.contentMode = .scaleAspectFill
                imageSelected = true
                
                guard let image = profileImg.image, imageSelected == true else {
                    print("JAKE: image must be selected")
                    return
                }
                
                if let imageData = UIImageJPEGRepresentation(image, 0.2) {
                    let imageUid = NSUUID().uuidString
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    DataService.ds.REF_PROFILE_PICTURES.child(imageUid).putData(imageData, metadata: metaData) { (metaData, error) in
                        if error != nil {
                            print("JAKE: unable to upload image to storage")
                        } else {
                            print("JAKE: successful upload image to storage")
                            let downloadUrl = metaData?.downloadURL()?.absoluteString
                            if let url = downloadUrl {
                                if let currentUser = Auth.auth().currentUser?.uid {
                                    DataService.ds.REF_USERS.child(currentUser).updateChildValues(["profilePicUrl": url] as Dictionary<String, Any> )
                                    //print("2: \(self.toBeDeletedProfRef)")
                                    let deletedImgRef = Storage.storage().reference(forURL: self.toBeDeletedProfRef)
                                    deletedImgRef.delete(completion: { (error) in
                                        if error != nil {
                                            print("error")
                                            //handle error
                                        } else {
                                            print("deleted")
                                        }
                                    })
                                    //ActivityFeedVC.imageCache.setObject(image, forKey: currentUser.profilePicUrl as NSString)
                                    
                                }
                                
                            }
                        }
                    }
                }
                
            } else if imagePicked == 2 {
                coverImg.image = image
                coverImg.contentMode = .scaleAspectFill
                imageSelected = true
                
                guard let image = coverImg.image, imageSelected == true else {
                    print("JAKE: image must be selected")
                    return
                }
                
                if let imageData = UIImageJPEGRepresentation(image, 0.2) {
                    let imageUid = NSUUID().uuidString
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    DataService.ds.REF_BACKGROUND_PICTURES.child(imageUid).putData(imageData, metadata: metaData) { (metaData, error) in
                        if error != nil {
                            print("JAKE: unable to upload image to storage")
                        } else {
                            print("JAKE: successful upload image to storage")
                            
                            let downloadUrl = metaData?.downloadURL()?.absoluteString
                            if let url = downloadUrl {
                                if let currentUser = Auth.auth().currentUser?.uid {
                                    DataService.ds.REF_USERS.child(currentUser).child("cover").updateChildValues(["source": url] as Dictionary<String, Any> )
                                    let deletedImgRef = Storage.storage().reference(forURL: self.toBeDeletedCoverRef)
                                    deletedImgRef.delete(completion: { (error) in
                                        if error != nil {
                                            print("error")
                                            //handle error
                                        } else {
                                            //print("deleted")
                                        }
                                    })
                                }
                                
                            }
                        }
                    }
                }
            }
            
            
        } else {
            print("JAKE: Valid image not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func populateProfilePicture(user: Users) {
        
        if user.id == "a" {
            profileImgPicker.isHidden = false
        }
        
        ImageCache.default.retrieveImage(forKey: user.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.profileImg.image = image
            } else {
                print("not in cache")
                if user.id != "a" {
                    let profileUrl = URL(string: user.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profileImg.image = profileImage
                        //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                        ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //print("JAKE: unable to download image from storage")
                        } else {
                            //print("JAKE: image downloaded from storage")
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profileImg.image = profileImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(profileImage, forKey: user.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
    


        //print("JAKE: going in to else")
//        if user.id != "a" {
//            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
//                profileImg.image = image
//                //print("JAKE: Cache working")
//            } else {
//                let profileUrl = URL(string: user.profilePicUrl)
//                let data = try? Data(contentsOf: profileUrl!)
//                if let profileImage = UIImage(data: data!) {
//                    self.profileImg.image = profileImage
//                    ActivityFeedVC.imageCache.setObject(profileImage, forKey: user.profilePicUrl as NSString)
//                }
//            }
//        } else {
//            profileImgPicker.isHidden = false
//            if let image = ActivityFeedVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
//                profileImg.image = image
//                //print("JAKE: Cache working")
//            } else {
//                let profPicRef = Storage.storage().reference(forURL: user.profilePicUrl)
//                profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        //print("JAKE: unable to download image from storage")
//                    } else {
//                        //print("JAKE: image downloaded from storage")
//                        if let imageData = data {
//                            if let image = UIImage(data: imageData) {
//                                self.profileImg.image = image
//                                ActivityFeedVC.imageCache.setObject(image, forKey: user.profilePicUrl as NSString)
//                                //self.postImg.image = image
//                                //FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
//                            }
//                        }
//                    }
//                })
//            }
//            
//        }
    }
    
    func populateCoverPicture(user: Users) {
        
        if user.id == "a" {
            self.coverImgPicker.isHidden = false
        }
        
        ImageCache.default.retrieveImage(forKey: user.cover["source"] as! String, options: nil) { (coverImage, cacheType) in
            if let image = coverImage {
                //print("Get image \(image), cacheType: \(cacheType).")
                self.coverImg.image = image
            } else {
                //print("not in cache")
                if user.id != "a" {
                    let coverUrl = URL(string: user.cover["source"] as! String)
                    let data = try? Data(contentsOf: coverUrl!)
                    if let coverImage = UIImage(data: data!) {
                        self.coverImg.image = coverImage
                        //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                        ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                    }
                    
                } else {
                    let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
                    coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //print("JAKE: unable to download image from storage")
                        } else {
                            //print("JAKE: image downloaded from storage")
                            if let imageData = data {
                                if let coverImage = UIImage(data: imageData) {
                                    self.coverImg.image = coverImage
                                    //ActivityFeedVC.imageCache.setObject(profileImage, forKey: users[index].profilePicUrl as NSString)
                                    ImageCache.default.store(coverImage, forKey: user.cover["source"] as! String)
                                }
                            }
                        }
                    })
                }
            }
        }
        
//        if user.id != "a" {
//            
//            if let coverStorageUrl = user.cover["source"] as? String {
//                
//                if let image = ActivityFeedVC.imageCache.object(forKey: coverStorageUrl as NSString) {
//                    //print("using cache")
//                    coverImg.image = image
//                }
//                else {
//                    //print("downloading")
//                    let coverUrl = URL(string: user.cover["source"] as! String)
//                    let data = try? Data(contentsOf: coverUrl!)
//                    if let coverImage = UIImage(data: data!) {
//                        self.coverImg.image = coverImage
//                        ActivityFeedVC.imageCache.setObject(coverImage, forKey: coverStorageUrl as NSString)
//                    }
//                }
//            }
//            
//        } else {
//            coverImgPicker.isHidden = false
//            if let coverStorageUrl = user.cover["source"] as? String {
//                
//                if let image = ActivityFeedVC.imageCache.object(forKey: coverStorageUrl as NSString) {
//                    //print("using cache")
//                    coverImg.image = image
//                } else {
//                    //print("downloading")
//                    let coverPicRef = Storage.storage().reference(forURL: user.cover["source"] as! String)
//                    coverPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                        if error != nil {
//                            //print("JAKE: unable to download image from storage")
//                        } else {
//                            //print("JAKE: image downloaded from storage")
//                            if let imageData = data {
//                                if let image = UIImage(data: imageData) {
//                                    self.coverImg.image = image
//                                    ActivityFeedVC.imageCache.setObject(image, forKey: coverStorageUrl as NSString)
//                                    
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//        }
    }
    
    func populateInformation(user: Users) {
        
        if user.isPrivate == true {
            privateProfileSwitch.isOn = true
        } else {
            privateProfileSwitch.isOn = false
        }
        
        nameTextField.text = user.name
        currentCityTextField.text = user.currentCity
        schoolTextField.text = user.school
        employerTextField.text = user.employer
        occupationTextField.text = user.occupation
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height - 50
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
        } else if textField == nameTextField {
            textField.resignFirstResponder()
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
    
    
    @IBAction func profileImgPickPressed(_ sender: UIButton) {
        imagePicked = sender.tag
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func coverImgPickPressed(_ sender: UIButton) {
        imagePicked = sender.tag
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if nameTextField.text == "" {
            nameTextField.attributedPlaceholder = NSAttributedString(string: "field cannot be empty",
                                                                     attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
            
            if let occupation = occupationTextField.text {
                if let employer = employerTextField.text {
                    if let currentCity = currentCityTextField.text {
                        if let school = schoolTextField.text {
                            if let name = nameTextField.text {
                                let childUpdates = ["isPrivate":setPrivate(privateSwitch: privateProfileSwitch),
                                                    "name":name,
                                                    "occupation":occupation,
                                                    "employer":employer,
                                                    "currentCity":currentCity,
                                                    "school":school] as [String: Any]
                                
                                if let currentUser = Auth.auth().currentUser?.uid {
                                    DataService.ds.REF_USERS.child(currentUser).updateChildValues(childUpdates)
                                }
                            }
                        }
                    }
                }
            }
            performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
        }
    }
    
    @IBAction func joinedListBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToJoinedList", sender: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToSearch", sender: nil)
    }
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToHome", sender: nil)
    }
    @IBAction func profileBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "editProfileToMyProfile", sender: nil)
        footerNewFriendIndicator.isHidden = true
    }
    
}
