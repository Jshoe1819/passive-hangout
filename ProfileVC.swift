//
//  ProfileVC.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 9/10/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "profileToActivityFeed", sender: nil)
    }
}
