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
    let number: String
    let name: String
    let topPrizesRemaining: String
    let rank: String
    
    enum CodingKeys: String, CodingKey {
        case price = "ft_price"
        case number = "ft_game_number"
        case name = "ft_game_name"
        case topPrizesRemaining = "ft_top_prizes_remaining"
        case rank = "ft_rank"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.price = try valueContainer.decode(String.self, forKey: CodingKeys.price)
        self.number = try valueContainer.decode(String.self, forKey: CodingKeys.number)
        self.name = try valueContainer.decode(String.self, forKey: CodingKeys.name)
        self.topPrizesRemaining = try valueContainer.decode(String.self, forKey: CodingKeys.topPrizesRemaining)
        self.rank = try valueContainer.decode(String.self, forKey: CodingKeys.rank)
    }
}
