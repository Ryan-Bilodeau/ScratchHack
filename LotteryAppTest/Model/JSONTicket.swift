//
//  JSONTicket.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 2/22/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

struct JSONTicket: Decodable {
    let price: String
    let number: String?
    let name: String
    let odds: String
    let prizesRemaining: String?
    let averageProfit: Double?
    let oddsRank: String
    let statsRank: String?
}

struct FormattedTicket {
    let price: Int
    let number: Int?
    let name: String
    let odds: Double
    let prizesRemaining: Double?
    let averageProfit: Double?
    let oddsRank: Int
    let statsRank: Int?
    
    init(price: Int, number: Int?, name: String, odds: Double, prizesRemaining: Double?, averageProfit: Double?, oddsRank: Int, statsRank: Int?) {
        self.price = price
        self.number = number
        self.name = name
        self.odds = odds
        self.prizesRemaining = prizesRemaining
        self.averageProfit = averageProfit
        self.oddsRank = oddsRank
        self.statsRank = statsRank
    }
    
    init(jsonTicket: JSONTicket) {
        if let number = jsonTicket.number {
            self.number = Int(number)
        } else {
            self.number = nil
        }
        
        if let prizesRemaining = jsonTicket.prizesRemaining {
            self.prizesRemaining = Double(prizesRemaining)
        } else {
            self.prizesRemaining = nil
        }
        
        if let averageProfit = jsonTicket.averageProfit {
            self.averageProfit = averageProfit
        } else {
            self.averageProfit = nil
        }
        
        if let statsRank = jsonTicket.statsRank {
            self.statsRank = Int(statsRank)
        } else {
            self.statsRank = nil
        }
        
        self.price = Int(jsonTicket.price) ?? -1
        self.name = jsonTicket.name
        self.odds = Double(jsonTicket.odds) ?? -1.0
        self.oddsRank = Int(jsonTicket.oddsRank) ?? -1
    }
}
