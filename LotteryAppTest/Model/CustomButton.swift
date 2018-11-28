//
//  CustomButton.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 2/25/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    var on: Bool = false
    var image: UIImage {
        switch self.tag {
        case 0:
            return on ? #imageLiteral(resourceName: "AscendingOn") : #imageLiteral(resourceName: "AscendingOff")
        case 1:
            return on ? #imageLiteral(resourceName: "DescendingOn") :#imageLiteral(resourceName: "DescendingOff")
        case 2:
            return on ? #imageLiteral(resourceName: "PriceOn") : #imageLiteral(resourceName: "PriceOff")
        case 3:
            return on ? #imageLiteral(resourceName: "IDOn") : #imageLiteral(resourceName: "IDOff")
        case 4:
            return on ? #imageLiteral(resourceName: "NameOn") : #imageLiteral(resourceName: "NameOff")
        case 5:
            return on ? #imageLiteral(resourceName: "TopPrizesLeftOn") : #imageLiteral(resourceName: "TopPrizesLeftOff")
        case 6:
            return on ? #imageLiteral(resourceName: "RankOn") : #imageLiteral(resourceName: "RankOff")
        default:
            return #imageLiteral(resourceName: "SortButton")
        }
    }
}
