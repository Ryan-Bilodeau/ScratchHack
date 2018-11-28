//
//  RightToLeftSegue.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/13/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

//Show help and main view controllers
class RightToLeftSegue: UIStoryboardSegue {
    override func perform() {
        let source = self.source
        let destination = self.destination
        
        source.view.superview?.insertSubview(destination.view, aboveSubview: source.view)
        
        destination.view.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            destination.view.transform = CGAffineTransform.identity
        }) { (true) in
            source.present(destination, animated: false, completion: nil)
        }
    }
}
