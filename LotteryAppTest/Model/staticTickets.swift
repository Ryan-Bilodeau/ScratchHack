//
//  staticTickets.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/30/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

class staticTickets {
    static let shared: staticTickets = staticTickets()
    
    var ownedStates: [State]!
    var unownedStates: [State]!
}
