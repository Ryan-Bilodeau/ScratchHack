//
//  StartViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 2/22/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class StartViewController: UIViewController {
    @IBOutlet weak var Circle0: UIImageView!
    @IBOutlet weak var Circle1: UIImageView!
    @IBOutlet weak var Circle2: UIImageView!
    @IBOutlet weak var Circle3: UIImageView!
    @IBOutlet weak var Circle4: UIImageView!
    @IBOutlet weak var Circle5: UIImageView!
    @IBOutlet weak var Circle6: UIImageView!
    @IBOutlet weak var Circle7: UIImageView!
    
    var loading = true
    var didSegue = false
    var unownedStates = [USAState]()
    var ownedStates = [USAState]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change back to load real products
        IAPService.shared.stateDelegate = self
        IAPService.shared.retrieveProductsInfo(products: IAPProduct.productIDs)
        animateCircles()
        
//        unownedStates = State.getTestUnpurchasedStates()
//        ownedStates = State.getTestPurchasedStates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            if self.loading && !self.didSegue{
                let alert = UIAlertController(title: "Error", message: "Loading is taking a while, you may need to try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
//    override func viewDidAppear(_ animated: Bool) {
//        performSegue(withIdentifier: "showStateView", sender: nil)
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "showStateView" else { return }
        if let stateViewController = segue.destination as? StateViewController {
            IAPService.shared.stateDelegate = nil
            stateViewController.unownedStates = self.unownedStates
            stateViewController.ownedStates = self.ownedStates
        }
        didSegue = true
    }
    
    func animateCircles() {
        let sizeIncrease:CGFloat = 2
        let duration: Double = 0.4
        let delay: Double = 0.15
        let restartDelay: Double = 0.5
        
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            self.Circle0.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle0.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 2, options: [], animations: {
            self.Circle1.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle1.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 3, options: [], animations: {
            self.Circle2.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle2.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 4, options: [], animations: {
            self.Circle3.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle3.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 5, options: [], animations: {
            self.Circle4.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle4.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 6, options: [], animations: {
            self.Circle5.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle5.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 7, options: [], animations: {
            self.Circle6.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle6.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        
        UIView.animate(withDuration: duration, delay: delay * 8, options: [], animations: {
            self.Circle7.transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
        }) { (true) in
            UIView.animate(withDuration: duration, animations: {
                self.Circle7.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (true) in
                print(self.unownedStates.count)
                if (self.unownedStates.count + self.ownedStates.count >= IAPProduct.productIDs.count) {
                    self.loading = false
                }
                if (self.loading) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + restartDelay, execute: {
                        self.animateCircles()
                    })
                } else {
                    self.performSegue(withIdentifier: "showStateView", sender: nil)
                }
            })
        }
    }
}

extension StartViewController: StateDelegate {
    func getState(state: USAState) {
        if state.purchased {
            //Remove from unowned states
            if unownedStates.count > 0 {
                for i in 0...unownedStates.count - 1 {
                    if state.state == unownedStates[i].state {
                        unownedStates.remove(at: i)
                    }
                }
            }
            
            //Add to owned states if not already in owned states
            var bought: Bool = false
            if ownedStates.count > 0 {
                for i in 0...ownedStates.count - 1 {
                    if state.state == ownedStates[i].state {
                        bought = true
                    }
                }
            }
            if !bought {
                ownedStates.append(state)
            }
        } else {
            //Remove from owned states if needed
            if ownedStates.count > 0 {
                for i in 0...ownedStates.count - 1 {
                    if ownedStates[i].state == state.state {
                        print("state removed" + ownedStates[i].name)
                        ownedStates.remove(at: i)
                    }
                }
            }
            
            //Add to unowned states if not already in unowned states
            var existing: Bool = false
            if unownedStates.count > 0 {
                for i in 0...unownedStates.count - 1 {
                    if state.state == unownedStates[i].state {
                        existing = true
                    }
                }
            }
            if !existing {
                unownedStates.append(state)
            }
        }
    }
}







