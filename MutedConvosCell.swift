//
//  MutedConvosCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 1/27/18.
//  Copyright © 2018 Jacob Shoemaker. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher

class MutedConvosCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: FeedProfilePic!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var primaryLbl: UILabel!
    @IBOutlet weak var mutedSwitch: UISwitch!
    
    weak var cellDelegate: MutedConvosDelegate?
    
    override func awakeFromNib() {
        mutedSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
    }
    
    func configureCell(users: Users) {
        
        mutedSwitch.isOn = true

        nameLbl.text = users.name
        primaryLbl.text = users.currentCity
        
        ImageCache.default.retrieveImage(forKey: users.profilePicUrl, options: nil) { (profileImage, cacheType) in
            if let image = profileImage {
                self.profilePic.image = image
            } else {
                if users.id != "a" {
                    let profileUrl = URL(string: users.profilePicUrl)
                    let data = try? Data(contentsOf: profileUrl!)
                    if let profileImage = UIImage(data: data!) {
                        self.profilePic.image = profileImage
                        ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                    }
                    
                } else {
                    let profPicRef = Storage.storage().reference(forURL: users.profilePicUrl)
                    profPicRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            //Handle error?
                        } else {
                            if let imageData = data {
                                if let profileImage = UIImage(data: imageData) {
                                    self.profilePic.image = profileImage
                                    ImageCache.default.store(profileImage, forKey: users.profilePicUrl)
                                }
                            }
                        }
                    })
                }
            }
        }
        
    }
     
    func switchChanged(mySwitch: UISwitch) {
        if mySwitch.isOn == true {
            cellDelegate?.mutedSwitchOn(self.tag)
        } else {
            cellDelegate?.mutedSwitchOff(self.tag)
        }
    }
    
}
