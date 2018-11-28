//
//  UnpurchasedUIButton.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/25/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class UnpurchasedUIButton: UIButton {
    var parent: UnpurchasedUIView!
    var unpurchasedDelegate: UnpurchasedStateClickedDelegate {
        return parent.controller
    }
    
    required init(parent: UnpurchasedUIView) {
        self.parent = parent
        super.init(frame: .zero)
        
        self.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.contentMode = .scaleToFill
        self.setImage(#imageLiteral(resourceName: "BlankCell0NoShadow"), for: .normal)
        self.setTitle(nil, for: .normal)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        setConstraints(parent: parent)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Private funcitons
extension UnpurchasedUIButton {
    func setConstraints(parent: UnpurchasedUIView) {
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
    }
}

//Actions
extension UnpurchasedUIButton {
    @objc func buttonPressed(sender: UnpurchasedUIButton!) {
        setCurrentStateClicked(controller: sender.parent.controller, state: sender.parent.state)
        unpurchasedDelegate.unpurchasedStateClicked(state: sender.parent.state)
    }
}

extension UnpurchasedUIButton: SetCurrentStateClickedDelegate {
    func setCurrentStateClicked(controller: StateViewController, state: USAState) {
        controller.currentUnpurchasedState = state
    }
}








