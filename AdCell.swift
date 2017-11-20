//
//  AdCell.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/16/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import UIKit
import GoogleMobileAds


class AdCell: UITableViewCell, GADBannerViewDelegate {
    
    @IBOutlet weak var view: UIView!
    var bannerView: GADBannerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
////        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        addBannerViewToView(bannerView)
////        bannerView.delegate = self
        
    }
    
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bannerView)
//        view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: bottomLayoutGuide,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//    }
    
    func cellBannerView(rootVC: UIViewController, frame: CGRect) -> GADBannerView {
        
        let bannerView = GADBannerView()
        
        bannerView.frame = frame
        
        bannerView.rootViewController = rootVC
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        bannerView.adSize = kGADAdSizeBanner
        
        bannerView.load(GADRequest())
        
        return bannerView
        
    }

    

}
