//
//  CenterToRightSegue.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/14/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

//Dismiss help and main view controllers
class CenterToRightSegue: UIStoryboardSegue {
    override func perform() {
        let source = self.source
        let destination = self.destination
        
        source.view.superview?.insertSubview(destination.view, belowSubview: source.view)
        
        source.view.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.25, animations: {
            source.view.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        }) { (true) in
            source.present(destination, animated: false, completion: nil)
        }
    }
}
