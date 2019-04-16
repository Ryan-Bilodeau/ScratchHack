//
//  Protocols.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/10/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation
import UIKit

protocol ResultDelegate {
    func result(result: Bool)
}

protocol StateUIButtonDelegate {
    func buttonDown(sender: StateUIButton)
    func buttonTouchUpInside(sender: StateUIButton)
    func buttonUp(sender: StateUIButton)
}
