////
////  SegueTopToBottom.swift
////  passive-hangout
////
////  Created by Jacob Shoemaker on 11/14/17.
////  Copyright © 2017 Jacob Shoemaker. All rights reserved.
////
//
//import UIKit
//
//class SegueTopToBottom: UIStoryboardSegue {
//    override func perform() {
//        var firstVCView = self.source.view as UIView!
//        var secondVCView = self.destination.view as UIView!
//        
//        // Get the screen width and height.
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//        
//        // Specify the initial position of the destination view.
//        secondVCView?.frame = CGRectMake(0.0, 0, screenWidth, screenHeight)
//        
//        // Access the app's key window and insert the destination view above the current (source) one.
//        let window = UIApplication.sharedApplication.keyWindow
//        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
//        
//        // Animate the transition.
//        UIView.animateWithDuration(2, animations: { () -> Void in
//            firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, screenHeight)
//            secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screenHeight)
//            
//        }) { (Finished) -> Void in
//            self.sourceViewController.presentViewController(self.destinationViewController as! UIViewController,
//                                                            animated: false,
//                                                            completion: nil)
//        }
//        
//    }
//}
