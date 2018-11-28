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

//Get available state, use in loop to get states
protocol StateDelegate {
    func getState(state: USAState)
}

//After buying state
protocol StatePurchasedDelegate {
    func statePurchased(state: USAState)
}

//Buying state failed
protocol StatePurchaseFailedDelegate {
    func statePurchaseFailed()
}

//On unpurchased state clicked
protocol UnpurchasedStateClickedDelegate {
    func unpurchasedStateClicked(state: USAState)
}

//On purchased state clicked
protocol PurchasedStateClickedDelegate {
    func purchasedStateClicked(state: USAState)
}

//Sets which state has been clicked
protocol SetCurrentStateClickedDelegate {
    func setCurrentStateClicked(controller: StateViewController, state: USAState)
}

//Notify when restoring purchases has finished
protocol RestorePurchasesFinishedDelegate {
    func restorePurchasesFinished(succeeded: Bool)
}
