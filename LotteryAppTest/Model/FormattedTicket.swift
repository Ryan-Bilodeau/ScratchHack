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
    let number: Int
    let name: String
    let topPrizesRemaining: Int
    let rank: Int
    
    var bestInPriceRange: Bool!
    var useGameNumbers: Bool {
        return number == -1 ? false : true
    }
    
    init(jsonTicket: JSONTicket) {
        self.price = Int(jsonTicket.price) ?? -1
        self.number = Int(jsonTicket.number) ?? -1
        self.name = jsonTicket.name
        self.topPrizesRemaining = Int(jsonTicket.topPrizesRemaining) ?? -1
        self.rank = Int(jsonTicket.rank) ?? -1
    }
}
