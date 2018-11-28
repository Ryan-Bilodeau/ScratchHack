//
//  FormattedTicketInfo.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/1/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

struct FormattedTicketInfo {
    let price: Int
    let percentAtStart: Double
    let percentUnclaimed: Double
    
    init(jsonTicketInfo: JSONTicketInfo) {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        self.price = Int(jsonTicketInfo.price) ?? -1
        self.percentAtStart = Double(jsonTicketInfo.percentAtStart) ?? -1
        self.percentUnclaimed = Double(jsonTicketInfo.percentUnclaimed) ?? -1
    }
}
