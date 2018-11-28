//
//  IAPService.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/24/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit
import SwiftyStoreKit

// The logic/structure for this class was mostly taken from YouTube here:
// https://www.youtube.com/watch?v=o3hJ0rY1NNw
class IAPService {
    static let shared = IAPService()
    let sharedSecret = ConfigData.SwiftyStoreKitSharedSecret
    
    var purchasedStateIds = [String]()
    var stateIds = [String]()
    
    var stateDelegate: StateDelegate?
    var statePurchasedDelegate: StatePurchasedDelegate?
    var statePurchaseFailedDelegate: StatePurchaseFailedDelegate?
    var restorePurchasesDelegate: RestorePurchasesFinishedDelegate?
    
    init() {}
    
    func retrieveProductsInfo(products: [String]) {
        for product in products {
            SwiftyStoreKit.retrieveProductsInfo([product]) { result in
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice!
                    print("Product: \(product.localizedDescription), price: \(priceString)")
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                }
                else {
                    print("Error: \(String(describing: result.error))")
                }
                
                self.stateIds.append(product)
                if self.stateIds.count == products.count {
                    self.onDoneRetrievingProducts()
                }
            }
        }
    }
    func verifySubscription(with id: String) {
        print("Verifying " + id)
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = id
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    
                    self.onSubscriptionPurchased(id: id, expiryDate: expiryDate)
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    
                    self.onSubscriptionExpired(id: id)
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                self.verifySubscription(with: id)
            }
        }
    }
    func purchaseSubscription(with id: String) {
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self.verifySubscription(with: id)
            } else {
                // purchase error
                self.statePurchaseFailedDelegate!.statePurchaseFailed()
            }
        }
    }
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.restorePurchasesDelegate?.restorePurchasesFinished(succeeded: false)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.restorePurchasesDelegate?.restorePurchasesFinished(succeeded: true)
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
}

//Stuff for getting and storing data
extension IAPService {
    private func onDoneRetrievingProducts() {
        for id in stateIds {
            if UserDefaults.standard.bool(forKey: id) {
                verifySubscription(with: id)    //Has purchased
            } else {
                if self.stateDelegate != nil {
                    self.stateDelegate!.getState(state: USAState(ID: id, purchased: false, expirationDate: nil)!)  //Hasn't purchased
                }
            }
        }
    }
    
    private func onSubscriptionExpired(id: String) {
        UserDefaults.standard.set(false, forKey: id)
        
        if self.stateDelegate != nil {
            self.stateDelegate!.getState(state: USAState(ID: id, purchased: false, expirationDate: nil)!)
        }
    }
    
    private func onSubscriptionPurchased(id: String, expiryDate: Date) {
        UserDefaults.standard.set(true, forKey: id)
        
        if self.stateDelegate != nil {
            self.stateDelegate!.getState(state: USAState(ID: id, purchased: true, expirationDate: expiryDate)!)
        }
        if self.statePurchasedDelegate != nil {
            self.statePurchasedDelegate!.statePurchased(state: USAState(ID: id, purchased: true, expirationDate: expiryDate)!)
        }
    }
}






