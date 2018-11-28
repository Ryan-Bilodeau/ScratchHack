//
//  JSONTicketInfo.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/1/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

struct JSONTicketInfo : Decodable {
    let price: String
    let percentAtStart: String
    let percentUnclaimed: String
    
    enum CodingKeys: String, CodingKey {
        case price = "tiT_price_point"
        case percentAtStart = "tiT_money_at_start"
        case percentUnclaimed = "tiT_money_unclaimed"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.price = try valueContainer.decode(String.self, forKey: CodingKeys.price)
        self.percentAtStart = try valueContainer.decode(String.self, forKey: CodingKeys.percentAtStart)
        self.percentUnclaimed = try valueContainer.decode(String.self, forKey: CodingKeys.percentUnclaimed)
    }
}
