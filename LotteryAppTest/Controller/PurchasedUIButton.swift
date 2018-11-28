//
//  PurchasedUIButton.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/25/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class PurchasedUIButton: UIButton {
    var parent: PurchasedUIView!
    var purchasedDelegate: PurchasedStateClickedDelegate {
        return parent.controller
    }
    
    required init(parent: PurchasedUIView) {
        self.parent = parent
        super.init(frame: .zero)
        
        self.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.contentMode = .scaleToFill
        self.setImage(#imageLiteral(resourceName: "BlankCell1NoShadow"), for: .normal)
        self.setTitle(nil, for: .normal)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        setConstraints(parent: parent)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Private functions
extension PurchasedUIButton {
    func setConstraints(parent: PurchasedUIView) {
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
    }
}

//Actions
extension PurchasedUIButton {
    @objc func buttonPressed(sender: UnpurchasedUIButton!) {
        purchasedDelegate.purchasedStateClicked(state: sender.parent.state)
        print("\(parent.state.name )Button pressed")
    }
}



