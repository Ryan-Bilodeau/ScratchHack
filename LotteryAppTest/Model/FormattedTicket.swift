//
//  FormattedTicket.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 2/22/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation
import UIKit

//Contructed from a JSONTicket object
struct FormattedTicket {
    let price: Int
    let number: Int?
    let name: String
    let odds: Double
    let oddsRank: Int
    let statsRank: Int?
    
    init(jsonTicket: JSONTicket) {
        self.price = Int(jsonTicket.price)!
        self.number = Int(jsonTicket.number) ?? -1
        self.name = jsonTicket.name
        self.topPrizesRemaining = Int(jsonTicket.topPrizesRemaining) ?? -1
        self.rank = Int(jsonTicket.rank) ?? -1
    }
}
