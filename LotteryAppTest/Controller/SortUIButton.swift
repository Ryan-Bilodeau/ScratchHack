//
//  SortUIButton.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/1/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import UIKit

class SortUIButton: UIButton {
    public var on: Bool = false {
        didSet {
            switch self.tag {
            case 0:
                self.setImage( on ? UIImage(named: "AscendingOn")! : UIImage(named: "AscendingOff")!, for: .normal)
            case 1:
                self.setImage( on ? UIImage(named: "DescendingOn")! : UIImage(named: "DescendingOff")!, for: .normal)
            case 2:
                self.setImage( on ? UIImage(named: "PriceOn")! : UIImage(named: "PriceOff")!, for: .normal)
            case 3:
                self.setImage( on ? UIImage(named: "IDOn")! : UIImage(named: "IDOff")!, for: .normal)
            case 4:
                self.setImage( on ? UIImage(named: "NameOn")! : UIImage(named: "NameOff")!, for: .normal)
            case 5:
                self.backgroundColor = on ? UIColor(red: 253 / 255, green: 213 / 255, blue: 90 / 255, alpha: 1) : UIColor(red: 191 / 255, green: 190 / 255, blue: 190 / 255, alpha: 1)
            case 6:
                self.setImage( on ? UIImage(named: "RankOn")! : UIImage(named: "RankOff")!, for: .normal)
            default:
                print("Error in SortUIButton: No matching case for button with tag \(self.tag)")
            }
        }
    }
}
