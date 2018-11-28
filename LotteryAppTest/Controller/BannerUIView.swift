//
//  BannerUIView.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/10/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class BannerUIView: UIView {
    var pic: UIImage!
    var name: String!
    var state: String!
    var amountWon: Int!
    var totalAmountWon: String! //This is a string so the format can be changed from the server
    
    let totalWinningsText = "Total Winnings"
    
    required init(pic: UIImage, name: String, state: String, amountWon: Int, totalAmountWon: String) {
        self.pic = pic
        self.name = name
        self.state = state
        self.amountWon = amountWon
        self.totalAmountWon = totalAmountWon
        
        super.init(frame: .zero)
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
