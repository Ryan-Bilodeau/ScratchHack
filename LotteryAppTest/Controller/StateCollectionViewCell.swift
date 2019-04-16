//
//  StateCollectionViewCell.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/16/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import UIKit

class StateCollectionViewCell: UICollectionViewCell {
    public var stateUIButton: StateUIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = false
        self.contentView.backgroundColor = .clear
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Interface Builder is not supported!")
    }
    
    public func setStateUIButton(stateName: String, abbreviation: String, delegate: StateUIButtonDelegate) {
        stateUIButton = StateUIButton(frame: .zero, name: stateName, abbreviation: abbreviation, parentCell: self, delegate: delegate)
    }
}
