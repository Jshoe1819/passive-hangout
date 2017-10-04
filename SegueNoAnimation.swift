//
//  SegueNoAnimation.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 10/3/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit

class SegueNoAnimation: UIStoryboardSegue {

    override func perform() {
        
        //let sourceVC = source as UIViewController
        let src = self.source
        let dst = self.destination
        src.navigationController?.pushViewController(dst as UIViewController, animated: false)
        if let navigation = src.navigationController {
            print("hi")
            navigation.pushViewController(dst as UIViewController, animated: false)
        }
        
    }
    
}
